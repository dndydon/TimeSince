//
//  Item.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/1/25.
//

import Foundation
import SwiftData

@Model
class Item: Identifiable, Hashable {
  // Stable identity separate from the user-visible name
  var id: UUID

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

  // Every Item must have exactly one ItemConfig
  var config: ItemConfig?

  init(
    id: UUID = UUID(),
    name: String,
    itemDescription: String,
    config: ItemConfig? = nil,
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
      self.config = ItemConfig(
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
    history.max(by: { $0.timestamp < $1.timestamp })?.timestamp
  }

  // Use latest event if present, otherwise fall back to createdAt
  var effectiveLastEventDate: Date {
    latestEventDate ?? createdAt
  }

  // Business rule: is this item due based on its config and last event?
  func isDue(now: Date = .now, calendar: Calendar = .current) -> Bool {
    guard let cfg = config else { return false }
    return RemindLogic.isDue(now: now, lastEvent: effectiveLastEventDate, config: cfg, calendar: calendar)
  }
}


// MARK: - Item date string formatting

/// Item timestamp relative date string formatter - subunits abbreviated
extension Item {
  public func timeSinceText(date: Date, showingRelative: Bool = true) -> String {
    let timeInterval = date.timeIntervalSince(self.lastModified)
    return showingRelative ? modernTimeIntervalString(timeInterval) + " ago" : modernTimeIntervalString(timeInterval)
  }

  /// Compute the String that describes the decimal number age of an Item from
  /// .timestamp (start) to date (end) using the most significant Calendar unit of the DateInterval.
  /// - Parameters:
  ///   - date: the end Date to compute the age to
  /// - Returns: String
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


@Model
class Event: Identifiable, Hashable {
  // Stable identity separate from the user-visible name
  var id: UUID

  var timestamp: Date
  var value: Double?
  var notes: String?

  // Make the parent relationship optional so SwiftData can clear it during deletion.
  var item: Item?

  // Require the owning Item at init time
  init(id: UUID = UUID(), item: Item, timestamp: Date = .now, value: Double? = nil, notes: String? = nil) {
    self.id = id
    self.item = item
    self.timestamp = timestamp
    self.value = value
    self.notes = notes
  }

  // MARK: - Hashable
  static func == (lhs: Event, rhs: Event) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

@Model
class ItemConfig: Identifiable, Hashable {
  // Stable identity separate from the user-visible name
  var id: UUID

  var configName: String
  var reminding: Bool
  var remindAt: Date
  var remindInterval: Int
  var timeUnits: Units

  init(id: UUID = UUID(), configName: String, reminding: Bool, remindAt: Date, remindInterval: Int, timeUnits: Units) {
    self.id = id
    self.configName = configName
    self.reminding = reminding
    self.remindAt = remindAt
    self.remindInterval = remindInterval
    self.timeUnits = timeUnits
  }

  // MARK: - Hashable
  static func == (lhs: ItemConfig, rhs: ItemConfig) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

@Model
class Settings: Identifiable, Hashable {
  // Stable identity separate from the user-visible name
  var id: UUID

  var displayTimesUsing: DisplayTimesUsing

  init(
    id: UUID = UUID(),
    displayTimesUsing: DisplayTimesUsing = .tenths
  ) {
    self.id = id
    self.displayTimesUsing = displayTimesUsing
  }

  // MARK: - Hashable
  static func == (lhs: Settings, rhs: Settings) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

enum DisplayTimesUsing: String, Codable {
  case tenths = "tenths"
  case subUnits = "subUnits"
}

enum Units: String, Codable {
  case minute
  case hour
  case day
  case week
  case month
  case year
}
