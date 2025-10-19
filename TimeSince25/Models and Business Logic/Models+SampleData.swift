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
      template.materialize(for: item, additionalHourOffset: (idx+1))
    }
    return item
  }
}

extension Event {
  // A lightweight template that can be turned into a real Event for a given Item.
  struct Template {
    // Negative timeInterval since now (e.g., -86400 for 1 day ago)
    let timeOffset: TimeInterval
    let value: Double?
    let notes: String?
  }

  // Public sample templates (10 entries) for tests/consumers that expect 10.
  static let sampleEventTemplates: [Template] = [
    Template(timeOffset: -(60*60*24*14), value: nil, notes: "Two weeks ago baseline"),
    Template(timeOffset: -(60*60*24*7 + 60*45), value: 5.0, notes: "Last week's session"),
    Template(timeOffset: -(60*60*24*3 + 60*60*6), value: nil, notes: "Three days ago"),
    Template(timeOffset: -(60*60*36), value: 1, notes: "Yesterday afternoon"),
    Template(timeOffset: -(60*60*6), value: nil, notes: "This morning"),
    Template(timeOffset: -(60*30), value: nil, notes: "About 30 minutes ago"),
    //Template(timeOffset: -(60*1), value: nil, notes: "1 minute ago"),
    //Template(timeOffset: (60*60*2), value: nil, notes: "In about 2 hours (future)"),
    //Template(timeOffset: (60*60*24), value: 45, notes: "Tomorrow (future)"),
    //Template(timeOffset: (60*60*24*3), value: nil, notes: "In three days (future)"),
    //Template(timeOffset: -(60*60*24*30), value: nil, notes: "About a month ago")
  ]

  // Backwards-compatible alias so existing tests referring to Event.sampleEvents still pass.
  // It returns the same count (10) but as templates rather than instantiated Events.
  static var sampleEvents: [Template] { sampleEventTemplates }
}

@MainActor
extension Event.Template {
  // Creates and attaches a new Event to the given item, applying an extra hour offset to diversify per-item histories.
  @discardableResult
  func materialize(for item: Item, additionalHourOffset: Int) -> Event {
    let totalOffset = timeOffset - TimeInterval(additionalHourOffset * 60 * 60)
    let ts = Date.now.addingTimeInterval(totalOffset)
    return item.createEvent(timestamp: ts, value: value, notes: notes)
  }
}

extension RemindConfig {
  @MainActor static let sampleConfigs: [RemindConfig] = [
    RemindConfig(configName: "5K Run Reminder", reminding: true,
                 remindAt: .now.addingTimeInterval(-(60*60*20)), remindInterval: 1, timeUnits: .day),
    RemindConfig(configName: "Coffee", reminding: true,
                 remindAt: .now.addingTimeInterval(-(60*20)), remindInterval: 2, timeUnits: .hour),
    RemindConfig(configName: "Medication", reminding: true,
                 remindAt: .now.addingTimeInterval(-(60*60*10)), remindInterval: 12, timeUnits: .hour),
    RemindConfig(configName: "Project Meeting", reminding: true,
                 remindAt: .now.addingTimeInterval((60*60*22)), remindInterval: 1, timeUnits: .week),
    RemindConfig(configName: "Groceries", reminding: true,
                 remindAt: .now.addingTimeInterval(-(60*60*24*6)), remindInterval: 7, timeUnits: .day),
    RemindConfig(configName: "Laundry", reminding: true,
                 remindAt: .now.addingTimeInterval(-(60*60*50)), remindInterval: 3, timeUnits: .day),
    RemindConfig(configName: "Water Plants", reminding: true,
                 remindAt: .now.addingTimeInterval((60*60*18)), remindInterval: 2, timeUnits: .day),
    RemindConfig(configName: "Workout", reminding: true,
                 remindAt: .now.addingTimeInterval(-(60*60*3)), remindInterval: 2, timeUnits: .day),
    RemindConfig(configName: "Call Mom", reminding: true,
                 remindAt: .now.addingTimeInterval((60*60*48)), remindInterval: 14, timeUnits: .day),
    RemindConfig(configName: "Car Service", reminding: true,
                 remindAt: .now.addingTimeInterval(-(60*60*24*180)), remindInterval: 6, timeUnits: .month)
  ]
}

extension Settings {
  @MainActor static var sample: Settings {
    Settings(displayTimesUsing: .tenths, showDetails: true)
  }
}

// MARK: - Preview SwiftData Container

@MainActor
extension ModelContainer {
  static var preview: ModelContainer = {
    let schema = Schema([
      Item.self,
      Event.self,
      RemindConfig.self,
      Settings.self
    ])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    let context = container.mainContext
    // Add all sample items (which include their sample event histories and configs)
    Item.sampleItems.forEach { context.insert($0) }
    // Insert a single sample settings row
    context.insert(Settings.sample)
    return container
  }()
}
