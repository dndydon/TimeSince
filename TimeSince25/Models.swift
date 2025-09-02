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

  init(name: String, itemDescription: String, history: [Event], config: ItemConfig? = nil) {
    self.name = name
    self.itemDescription = itemDescription
    self.history = history
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

  init(displayTimesUsing: DisplayTimesUsing = .tenths, /*displayTheme: Theme*/ ) {
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
//    init(font: String = "System", color: String = "primary") {
//        self.font = font
//        self.color = color
//    }
//}
