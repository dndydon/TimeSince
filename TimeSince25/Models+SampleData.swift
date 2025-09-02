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
      itemDescription: "Your daily 5K morning run.",
      config: .sampleConfigs[0]
    ),
    Item(
      name: "Coffee Break",
      itemDescription: "How long since your last coffee?",
      config: .sampleConfigs[1]
    ),
    Item(
      name: "Medication",
      itemDescription: "Track your morning medication.",
      config: .sampleConfigs[2]
    ),
    Item(
      name: "Project Meeting",
      itemDescription: "Weekly project sync-up.",
      config: .sampleConfigs[3]
    ),
    Item(
      name: "Grocery Shopping",
      itemDescription: "Time since last grocery trip.",
      config: .sampleConfigs[4]
    ),
    Item(
      name: "Laundry",
      itemDescription: "Laundry cycle tracker.",
      config: .sampleConfigs[5]
    ),
    Item(
      name: "Water Plants",
      itemDescription: "How often you water your plants.",
      config: .sampleConfigs[6]
    ),
    Item(
      name: "Workout",
      itemDescription: "Track your gym workouts.",
      config: .sampleConfigs[7]
    ),
    Item(
      name: "Call Mom",
      itemDescription: "How long since you called Mom?",
      config: .sampleConfigs[8]
    ),
    Item(
      name: "Car Service",
      itemDescription: "Track time between car services.",
      config: .sampleConfigs[9]
    ),
  ].enumerated().map { (idx, item) in
    // Build event history for each item from the event templates,
    // applying a per-item offset so lists look varied.
    Event.sampleEventTemplates.forEach { template in
      template.materialize(for: item, additionalHourOffset: idx * 3)
    }
    return item
  }
}

@MainActor
extension Event {
  // A lightweight template that can be turned into a real Event for a given Item.
  struct Template {
    // Negative timeInterval since now (e.g., -86400 for 1 day ago)
    let timeOffset: TimeInterval
    let value: Double?
    let notes: String?

    // Creates and attaches a new Event to the given item, applying an extra hour offset to diversify per-item histories.
    @discardableResult
    func materialize(for item: Item, additionalHourOffset: Int = 0) -> Event {
      let totalOffset = timeOffset - TimeInterval(additionalHourOffset * 60 * 60)
      let ts = Date.now.addingTimeInterval(totalOffset)
      return item.createEvent(timestamp: ts, value: value, notes: notes)
    }
  }

  // Public sample templates (10 entries) for tests/consumers that expect 10.
  static let sampleEventTemplates: [Template] = [
    Template(timeOffset: -(60*60*24), value: 5.2, notes: "Great run!"),
    Template(timeOffset: -(60*60*3), value: 1, notes: "Espresso shot"),
    Template(timeOffset: -(60*60*7), value: nil, notes: "Took meds on time"),
    Template(timeOffset: -(60*60*24*2), value: nil, notes: "Weekly meeting"),
    Template(timeOffset: -(60*60*24*3), value: 60, notes: "Grocery haul"),
    Template(timeOffset: -(60*60*24*1.5), value: nil, notes: "Laundry done"),
    Template(timeOffset: -(60*60*24*0.75), value: nil, notes: "Watered plants"),
    Template(timeOffset: -(60*60*2), value: 45, notes: "Workout complete"),
    Template(timeOffset: -(60*60*24*6), value: nil, notes: "Nice chat with Mom"),
    Template(timeOffset: -(60*60*24*7), value: nil, notes: "Oil changed"),
  ]

  // Backwards-compatible alias so existing tests referring to Event.sampleEvents still pass.
  // It returns the same count (10) but as templates rather than instantiated Events.
  static var sampleEvents: [Template] { sampleEventTemplates }
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
