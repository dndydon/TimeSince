//
//  Item.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/29/25.
//

import Foundation
import SwiftData
import DSRelativeTimeFormatter


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
        configName: "Repeat daily",
        reminding: false,
        remindAt: .now,
        remindInterval: 1,
        timeUnits: .day
      )
    }
    self.createdAt = createdAt
    self.lastModified = lastModified
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
    // Do NOT set lastModified = .now here.
    // Let the caller recalc from events to keep it consistent with event timestamps.
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


// MARK: - Item date string formatting (moved)
// Formatting helpers were removed from `Item` to keep concerns separated.
// Call `DSRelativeTimeFormatter` directly from views/view models, passing
// `from: item.lastModified` and `to: now` as needed.

