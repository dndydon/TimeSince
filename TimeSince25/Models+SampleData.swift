//  Models+SampleData.swift
//  TimeSince25
//
//  Created for preview/sample data support.

import Foundation
import SwiftData

@MainActor
extension Item {
  static let sampleItems: [Item] = [
    Item(
      name: "Morning Run",
      itemDescription: "Your daily 5K morning run.", history: [],
      config: .sampleConfigs[0]
    ),
    Item(
      name: "Coffee Break",
      itemDescription: "How long since your last coffee?", history: [],
      config: .sampleConfigs[1]
    ),
    Item(
      name: "Medication",
      itemDescription: "Track your morning medication.", history: [],
      config: .sampleConfigs[2]
    ),
    Item(
      name: "Project Meeting",
      itemDescription: "Weekly project sync-up.", history: [],
      config: .sampleConfigs[3]
    ),
    Item(
      name: "Grocery Shopping",
      itemDescription: "Time since last grocery trip.", history: [],
      config: .sampleConfigs[4]
    ),
    Item(
      name: "Laundry",
      itemDescription: "Laundry cycle tracker.", history: [],
      config: .sampleConfigs[5]
    ),
    Item(
      name: "Water Plants",
      itemDescription: "How often you water your plants.", history: [],
      config: .sampleConfigs[6]
    ),
    Item(
      name: "Workout",
      itemDescription: "Track your gym workouts.", history: [],
      config: .sampleConfigs[7]
    ),
    Item(
      name: "Call Mom",
      itemDescription: "How long since you called Mom?", history: [],
      config: .sampleConfigs[8]
    ),
    Item(
      name: "Car Service",
      itemDescription: "Track time between car services.", history: [],
      config: .sampleConfigs[9]
    ),
  ].enumerated().map { (idx, item) in
    item.history = Event.sampleEvents.map { $0.copyWith(offset: idx * 3) }
    return item
  }
}

@MainActor
extension Event {
  static let sampleEvents: [Event] = [
    Event(timestamp: .now - 60*60*24, value: 5.2, notes: "Great run!"),
    Event(timestamp: .now - 60*60*3, value: 1, notes: "Espresso shot"),
    Event(timestamp: .now - 60*60*7, value: nil, notes: "Took meds on time"),
    Event(timestamp: .now - 60*60*24*2, value: nil, notes: "Weekly meeting"),
    Event(timestamp: .now - 60*60*24*3, value: 60, notes: "Grocery haul"),
    Event(timestamp: .now - 60*60*24*1.5, value: nil, notes: "Laundry done"),
    Event(timestamp: .now - 60*60*24*0.75, value: nil, notes: "Watered plants"),
    Event(timestamp: .now - 60*60*2, value: 45, notes: "Workout complete"),
    Event(timestamp: .now - 60*60*24*6, value: nil, notes: "Nice chat with Mom"),
    Event(timestamp: .now - 60*60*24*7, value: nil, notes: "Oil changed"),
  ]
  
  // Helper for offsetting timestamps
  func copyWith(offset: Int) -> Event {
    Event(timestamp: self.timestamp.addingTimeInterval(TimeInterval(offset * 60 * 60)), value: self.value, notes: self.notes)
  }
}

@MainActor
extension ItemConfig {
  static let sampleConfigs: [ItemConfig] = [
    ItemConfig(configName: "5K Run Reminder", reminding: true, remindAt: .now.addingTimeInterval(3600), remindInterval: 1, timeUnits: .day),
    ItemConfig(configName: "Coffee", reminding: false, remindAt: .now, remindInterval: 4, timeUnits: .hour),
    ItemConfig(configName: "Medication", reminding: true, remindAt: .now.addingTimeInterval(28800), remindInterval: 1, timeUnits: .day),
    ItemConfig(configName: "Project Meeting", reminding: true, remindAt: .now, remindInterval: 1, timeUnits: .week),
    ItemConfig(configName: "Groceries", reminding: false, remindAt: .now, remindInterval: 7, timeUnits: .day),
    ItemConfig(configName: "Laundry", reminding: true, remindAt: .now.addingTimeInterval(43200), remindInterval: 3, timeUnits: .day),
    ItemConfig(configName: "Water Plants", reminding: true, remindAt: .now.addingTimeInterval(21600), remindInterval: 2, timeUnits: .day),
    ItemConfig(configName: "Workout", reminding: true, remindAt: .now.addingTimeInterval(32400), remindInterval: 2, timeUnits: .day),
    ItemConfig(configName: "Call Mom", reminding: false, remindAt: .now, remindInterval: 14, timeUnits: .day),
    ItemConfig(configName: "Car Service", reminding: true, remindAt: .now, remindInterval: 6, timeUnits: .month)
  ]
}

@MainActor
extension Settings {
  static let sampleSettings: [Settings] = [
    Settings(displayTimesUsing: .tenths),
    Settings(displayTimesUsing: .subUnits)
  ]
}

// MARK: - Preview SwiftData Container

@MainActor
extension ModelContainer {
  static var preview: ModelContainer = {
    let schema = Schema([
      Item.self,
      Event.self,
      ItemConfig.self,
      Settings.self
    ])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    let context = container.mainContext
    // Add all sample items (which include their sample event histories and configs)
    Item.sampleItems.forEach { context.insert($0) }
    // Insert sample settings if desired
    Settings.sampleSettings.forEach { context.insert($0) }
    return container
  }()
}
