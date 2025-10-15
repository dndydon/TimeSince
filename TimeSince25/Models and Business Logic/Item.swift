//
//  Item.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/29/25.
//

import Foundation
import SwiftData


@Model
class Item: Identifiable, Hashable {
  // Stable identity separate from the user-visible name
  var id: UUID

/* Business Rules

   To ensure that each Item has a unique name—meaning no two Items
   can share the same name—we need to introduce a validation step. While
   SwiftData provides the #Unique macro for enforcing uniqueness, it
   doesn’t throw an error or offer a clean way to handle violations
   when the rule is broken.

    As a workaround, we can implement an exists function in the Item model
    that checks whether a Item with the given name already exists in the database.

    Although it’s possible to place this logic directly in the ItemListView,
    a better approach is to encapsulate it within the Item class. This not
    only makes the code more reusable and easier to maintain but also enables
    unit testing the logic independently of the UI layer.
*/

  // Unique and indexed for faster search
  @Attribute(.unique)
  var name: String
  var itemDescription: String

  // Track creation and updates for sorting/filtering
  var createdAt: Date
  var lastModified: Date

  // Each Item has one or more Events; inverse is Event.item
  @Relationship(deleteRule: .cascade, inverse: \Event.item)
  var history: [Event] = []

  // Every Item must have exactly one RemindConfig
  var config: RemindConfig?

  init(
    id: UUID = UUID(),
    name: String,
    itemDescription: String,
    config: RemindConfig? = nil,
    createdAt: Date = .now,
    lastModified: Date = .now
  ) {
    self.id = id
    self.name = name
    self.itemDescription = itemDescription
    // Enforce: every Item has a config. If none provided, create a default one.
    if let provided = config {
      self.config = provided
    } else {
      self.config = RemindConfig(
        configName: "Default",
        reminding: false,
        remindAt: .now,
        remindInterval: 1,
        timeUnits: .day
      )
    }
    self.createdAt = createdAt
    self.lastModified = .now
    // Create an initial event linked to this item (createEvent appends it)
    _ = createEvent()
  }

  // MARK: - Hashable
  static func == (lhs: Item, rhs: Item) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  // Use this to enforce business logic on unique name for Items
  static func exists(context: ModelContext, name: String, excluding idToExclude: UUID? = nil) throws -> Bool {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

    if let id = idToExclude {
      let predicate = #Predicate<Item> { item in
        item.name == trimmed && item.id != id
      }
      var descriptor = FetchDescriptor<Item>(predicate: predicate)
      descriptor.fetchLimit = 1
      let results = try context.fetch(descriptor)
      return !results.isEmpty
    } else {
      let predicate = #Predicate<Item> { item in
        item.name == trimmed
      }
      var descriptor = FetchDescriptor<Item>(predicate: predicate)
      descriptor.fetchLimit = 1
      let results = try context.fetch(descriptor)
      return !results.isEmpty
    }
  }

  // Convenience to add an Event and maintain the inverse
  func addEvent(_ event: Event) {
    // Reassign to this Item to ensure inverse is correct
    event.item = self
    if history.contains(where: { $0 === event }) == false {
      history.append(event)
    }
    self.lastModified = .now
  }

  // Convenience to create and add an Event in one call
  @discardableResult
  func createEvent(timestamp: Date = .now, value: Double? = nil, notes: String? = nil) -> Event {
    // Require the owning Item when creating an Event
    let event = Event(item: self, timestamp: timestamp, value: value, notes: notes)
    history.append(event)
    lastModified = timestamp  //.now
    return event
  }

  private func lastModifiedDateString() -> String {
    let str = self.lastModified.formatted(date: .abbreviated, time: .standard)
    return str
  }

}


// MARK: - Domain helpers for Item

extension Item {
  // Latest event
  var latestEvent: Event? {
    history.max(by: { $0.timestamp < $1.timestamp })
  }

  // Latest event timestamp if any
  var latestEventDate: Date? {
    latestEvent?.timestamp
  }

  // Use latest event if present, otherwise fall back to createdAt
  var effectiveLastEventDate: Date {
    latestEventDate ?? createdAt
  }

  // Business rule: is this item due based on its config and last event?
  @MainActor
  func isDue(now: Date = .now, calendar: Calendar = .current) -> Bool {
    guard let cfg = config else { return false }
    return RemindLogic.isDue(now: now, lastEvent: effectiveLastEventDate, config: cfg, calendar: calendar)
  }


  // Business validation: ensure unique item name or throw
  static func validateUniqueName(context: ModelContext, name: String, excluding idToExclude: UUID? = nil) throws {
    if try exists(context: context, name: name, excluding: idToExclude) {
      throw ItemError.duplicateName
    }
  }
}


// MARK: - Item date string formatting

/// Item timestamp relative date string formatter - subunits abbreviated
extension Item {
  @MainActor
  public func timeSinceText(date: Date, showingRelative: Bool = true) -> String {
    let timeInterval = date.timeIntervalSince(self.lastModified)
    return showingRelative ? modernTimeIntervalString(timeInterval) + " ago" : modernTimeIntervalString(timeInterval)
  }

  /// Compute the String that describes the decimal number age of an Item from
  /// .timestamp (start) to date (end) using the most significant Calendar unit of the DateInterval.
  /// - Parameters:
  ///   - date: the end Date to compute the age to
  /// - Returns: String
  @MainActor
  public func decimalTimeSinceText(date: Date, showingRelative: Bool = true) -> String {
    // Measure from the item's lastModified (or latest event) to the provided date.
    let start = self.lastModified
    let end = date

    // Guard against inverted intervals; treat negative durations as zero.
    let duration = max(0, end.timeIntervalSince(start))
    //let duration = date.timeIntervalSince(self.lastModified)  // DDS  (what if we WANT to allow negative intervals, future dates?)

    // Choose the most significant unit that fits the duration.
    // Uses average month/year lengths defined in Calendar.Component.standardTimeInterval().
    let unit: Calendar.Component = {
      if let year   = Calendar.Component.year.standardTimeInterval(), duration >= year { return .year }
      if let month  = Calendar.Component.month.standardTimeInterval(), duration >= month { return .month }
      if let week   = Calendar.Component.weekOfYear.standardTimeInterval(), duration >= week { return .weekOfYear }
      if let day    = Calendar.Component.day.standardTimeInterval(), duration >= day { return .day }
      if let hour   = Calendar.Component.hour.standardTimeInterval(), duration >= hour { return .hour }
      if let minute = Calendar.Component.minute.standardTimeInterval(), duration >= minute { return .minute }
      return .second
    }()

    // Compute approximate decimal age in the chosen unit.
    let age: Decimal = date.decimalAge(start: start, end: end, unit: unit)
    assert(age.isNaN == false)

    // Format with one fractional digit to match decimalAge behavior/expectation.
    let ageString = age.formatted(.number.precision(.fractionLength(1)))

    let symbol = Item.shortSymbol(for: unit)
    return showingRelative ? "\(ageString) \(symbol) ago" : "\(ageString) \(symbol)"
  }

  // Abbreviated symbols for supported units, with simple pluralization.
  // - note: since we are using short abbreviations, we only need/want singular units.
  // Fallback to Calendar.Component description if we encounter an unsupported unit.
  private static func shortSymbol(for unit: Calendar.Component) -> String {
    switch unit {
      case .second: return "s"
      case .minute: return "min"
      case .hour:   return "hr"
      case .day:    return "d"
      case .weekOfMonth, .weekOfYear: return "wk"
      case .month:  return "mo"
      case .year:   return "yr"
      default:
        // Reasonable fallback; you can expand mapping if you plan to support more units.
        return String(describing: unit)
    }
  }
}
