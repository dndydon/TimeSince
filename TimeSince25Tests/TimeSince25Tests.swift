//
//  TimeSince25Tests.swift
//  TimeSince25Tests
//
//  Created by Don Sleeter on 9/1/25.
//

import Testing
import CoreTransferable
import SwiftData

@MainActor
struct TimeSince25Tests {
  @Test("CRUD for Item")
  func testCRUDItem() async throws {
    print("--- Item CRUD ---")
    let item = Item(name: "Test Item", itemDescription: "Testing", config: nil)
    #expect(item.name == "Test Item")
    item.name = "Updated Name"
    #expect(item.name == "Updated Name")
    // Delete simulation: just nil out the reference for now
    var itemOpt: Item? = item
    print("TestItem: \(itemOpt.debugDescription)")
    itemOpt = nil
    print("Item deleted (set to nil)")
  }

  @Test("CRUD for Event")
  func testCRUDEvent() async throws {
    print("--- Event CRUD ---")
    let event = Event(timestamp: Date.now, value: 2.5, notes: "Sample")
    #expect(event.value == 2.5)
    event.value = 99.9
    #expect(event.value == 99.9)
    // Delete simulation
    var eventOpt: Event? = event
    print("TestEvent: \(eventOpt.debugDescription)")
    eventOpt = nil
    print("Event deleted (set to nil)")
  }

  @Test("CRUD for ItemConfig")
  func testCRUDItemConfig() async throws {
    print("--- ItemConfig CRUD ---")
    let cfg = ItemConfig(configName: "Config1", reminding: true, remindAt: Date.now, remindInterval: 5, timeUnits: Units.day)
    #expect(cfg.configName == "Config1")
    cfg.reminding = false
    #expect(cfg.reminding == false)
    // Delete simulation
    var cfgOpt: ItemConfig? = cfg
    print("TestConfig: \(cfgOpt.debugDescription)")
    cfgOpt = nil
    print("ItemConfig deleted (set to nil)")
  }

  @Test("CRUD for Settings")
  func testCRUDSettings() async throws {
    print("--- Settings CRUD ---")
    //let thm = Theme(font: "System", color: "Red")
    let settings = Settings(displayTimesUsing: DisplayTimesUsing.tenths, /*displayTheme: thm*/)
    #expect(settings.displayTimesUsing == DisplayTimesUsing.tenths)
    //settings.displayTheme = Theme(font: "Avenir", color: "Blue")
    //#expect(settings.displayTheme.font == "Avenir")
    // Delete simulation
    var sOpt: Settings? = settings
    print("TestSettings: \(sOpt.debugDescription)")
    sOpt = nil
    print("Settings deleted (set to nil)")
  }

  @Test("Relationships for Item")
  func testItemRelationships() async throws {
    print("--- Item Relationships ---")
    let cfg = ItemConfig(configName: "RelConfig", reminding: false, remindAt: Date.now, remindInterval: 1, timeUnits: Units.day)
    let item = Item(name: "RelItem", itemDescription: "With relationships", config: cfg)
    let ev1 = Event(timestamp: Date.now, value: 1, notes: "First")
    let ev2 = Event(timestamp: Date.now, value: 2, notes: "Second")
    item.history.append(ev1)
    item.history.append(ev2)
    #expect(item.config?.configName == "RelConfig")
    #expect(item.history.count == 2)
    #expect(item.history.first?.notes == "First")
    // Remove one event
    item.history.removeFirst()
    #expect(item.history.count == 1)
    print("Remaining event notes: \(item.history.first?.notes ?? "none")")
  }

  @Test("SampleData sanity checks")
  func testSampleData() async throws {
    print("--- SampleData Sanity ---")
    // Item sample data
    #expect(!Item.sampleItems.isEmpty, "Item.sampleItems should not be empty")
    #expect(Item.sampleItems.count == 10, "Should be 10 sample items")
    #expect(Item.sampleItems[0].name == "Morning Run")
    #expect(Item.sampleItems[1].itemDescription.contains("coffee"), "Second item's description includes 'coffee'")
    #expect(Item.sampleItems[0].config?.configName == "5K Run Reminder")
    #expect(Item.sampleItems[0].history.count == Event.sampleEvents.count, "Each sample item should have a full history")
    print(Item.sampleItems.map { item in
      "\(item.name) has \(item.history.count) events"
    })

    // Event sample data
    #expect(Event.sampleEvents.count == 10, "Should be 10 sample events")
    #expect(Event.sampleEvents[0].notes == "Great run!")
    #expect(Event.sampleEvents[1].value == 1)

    // ItemConfig sample data
    #expect(ItemConfig.sampleConfigs.count == 10, "Should be 10 sample configs")
    #expect(ItemConfig.sampleConfigs[0].configName == "5K Run Reminder")
    #expect(ItemConfig.sampleConfigs[1].reminding == false)

    // Settings sample data
    #expect(Settings.sampleSettings.count == 2)
    #expect(Settings.sampleSettings[0].displayTimesUsing == .tenths)
    #expect(Settings.sampleSettings[1].displayTimesUsing == .subUnits)
  }
}

