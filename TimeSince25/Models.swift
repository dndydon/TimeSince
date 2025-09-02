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
    self.config = config
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
    lastModified = .now
    return event
  }

  private func lastModifiedDateString() -> String {
    let str = self.lastModified.formatted(date: .abbreviated, time: .standard)
    return str
  }

}

@Model
class Event {
  var timestamp: Date
  var value: Double?
  var notes: String?

  // Required single-valued inverse back to Item
  var item: Item

  // Require the owning Item at init time
  init(item: Item, timestamp: Date = .now, value: Double? = nil, notes: String? = nil) {
    self.item = item
    self.timestamp = timestamp
    self.value = value
    self.notes = notes
  }
}

@Model
class ItemConfig {
  var configName: String
  var reminding: Bool
  var remindAt: Date
  var remindInterval: Int
  var timeUnits: Units

  init(configName: String, reminding: Bool, remindAt: Date, remindInterval: Int, timeUnits: Units) {
    self.configName = configName
    self.reminding = reminding
    self.remindAt = remindAt
    self.remindInterval = remindInterval
    self.timeUnits = timeUnits
  }
}

@Model
class Settings {
  var displayTimesUsing: DisplayTimesUsing
  //var displayTheme: Theme

  init(displayTimesUsing: DisplayTimesUsing = .tenths /*, displayTheme: Theme */) {
    self.displayTimesUsing = displayTimesUsing
    //self.displayTheme = displayTheme
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

// You might want to expand Theme as needed, for now as a placeholder:
//struct Theme: Codable, Equatable {
//    var font: String
//    var color: String
//    
//    init(font: String = "System", color: "primary") {
//        self.font = font
//        self.color = color
//    }
//}

