//
//  Item.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/1/25.
//


import Foundation
import SwiftData

@Model
class Item {
  @Attribute(.unique)
  var name: String
  var itemDescription: String
  @Relationship(deleteRule: .cascade)
  var history: [Event] = []
  var config: ItemConfig?

  init(name: String, description: String, config: ItemConfig? = nil) {
    self.name = name
    self.itemDescription = description
    self.config = config
  }
}

@Model
class Event {
  var timestamp: Date
  var value: Double?
  var notes: String?

  init(timestamp: Date = .now, value: Double? = nil, notes: String? = nil) {
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

  init(description: String, reminding: Bool, remindAt: Date, remindInterval: Int, timeUnits: Units) {
    self.configName = description
    self.reminding = reminding
    self.remindAt = remindAt
    self.remindInterval = remindInterval
    self.timeUnits = timeUnits
  }
}

@Model
class Settings {
  var displayTimesUsing: DisplayTimesUsing
  var displayTheme: Theme

  init(displayTimesUsing: DisplayTimesUsing, displayTheme: Theme) {
    self.displayTimesUsing = displayTimesUsing
    self.displayTheme = displayTheme
  }
}

enum DisplayTimesUsing: Codable {
  case tenths
  case subUnits
}

enum Units: String, Codable {
  case day
  // add others as needed
}

// You might want to expand Theme as needed, for now as a placeholder:
struct Theme: Codable {
    var font: String
    var color: String

    enum CodingKeys: String, CodingKey {
        case font
        case color
    }

    init(font: String, color: String) {
        self.font = font
        self.color = color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        font = try container.decode(String.self, forKey: .font)
        color = try container.decode(String.self, forKey: .color)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(font, forKey: .font)
        try container.encode(color, forKey: .color)
    }
}
