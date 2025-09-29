//
//  TimeSince25TestsBundle.swift
//  TimeSince25TestsBundle
//
//  Created by Don Sleeter on 9/26/25.
//

import Testing
import CoreTransferable
import SwiftData
import SwiftUI

@testable import TimeSince25

@Suite("TimeSince25TestsBundle")
struct TimeSince25TestsBundle {
  @Test("CRUD for Item")
    func testCRUDItem() async throws {
      print("--- Item CRUD ---")
      let item = Item(name: "Test Item", itemDescription: "Testing", config: nil)
      #expect(item.name == "Test Item")
      item.name = "Updated Name"
      #expect(item.name == "Updated Name")
      var itemOpt: Item? = item
      print("TestItem: \(itemOpt.debugDescription)")
      itemOpt = nil
      print("Item deleted (set to nil)")
    }

    @Test("CRUD for Event")
    func testCRUDEvent() async throws {
      print("--- Event CRUD ---")
      let owner = Item(name: "Owner", itemDescription: "For event tests")
      let event = Event(item: owner, timestamp: .now, value: 2.5, notes: "Sample")
      #expect(event.value == 2.5)
      event.value = 99.9
      #expect(event.value == 99.9)
      var eventOpt: Event? = event
      print("TestEvent: \(eventOpt.debugDescription)")
      eventOpt = nil
      print("Event deleted (set to nil)")
    }

    @Test("CRUD for ItemConfig")
    func testCRUDItemConfig() async throws {
      print("--- ItemConfig CRUD ---")
      let cfg = ItemConfig(configName: "Config1", reminding: true, remindAt: .now, remindInterval: 5, timeUnits: .day)
      #expect(cfg.configName == "Config1")
      cfg.reminding = false
      #expect(cfg.reminding == false)
      var cfgOpt: ItemConfig? = cfg
      print("TestConfig: \(cfgOpt.debugDescription)")
      cfgOpt = nil
      print("ItemConfig deleted (set to nil)")
    }

    @Test("CRUD for Settings")
    func testCRUDSettings() async throws {
      print("--- Settings CRUD ---")
      let settings = Settings(displayTimesUsing: .tenths /*, displayTheme: thm*/)
      #expect(settings.displayTimesUsing == .tenths)
      var sOpt: Settings? = settings
      print("TestSettings: \(sOpt.debugDescription)")
      sOpt = nil
      print("Settings deleted (set to nil)")
    }

    @Test("Relationships for Item")
    func testItemRelationships() async throws {
      print("--- Item Relationships ---")
      let cfg = ItemConfig(configName: "RelConfig", reminding: false, remindAt: .now, remindInterval: 1, timeUnits: .day)
      let item = Item(name: "RelItem", itemDescription: "With relationships", config: cfg)
      #expect(item.history.count == 1)
      #expect(item.history.first?.notes == nil)
      let ev1 = Event(item: item, timestamp: .now, value: 1, notes: "First")
      let ev2 = Event(item: item, timestamp: .now, value: 2, notes: "Second")
      item.addEvent(ev1)
      item.addEvent(ev2)
      #expect(item.config?.configName == "RelConfig")
      #expect(item.history.count == 3)
      #expect(item.history.first?.notes == nil)
      // Remove one event
      item.history.removeFirst()
      #expect(item.history.count == 2)
      print("Remaining event notes: \(item.history.first?.notes ?? "none")")
    }

    @MainActor
    @Test("SampleData sanity checks")
    func testSampleData() async throws {
      print("--- SampleData Sanity ---")
      #expect(!Item.sampleItems.isEmpty, "Item.sampleItems should not be empty")
      #expect(Item.sampleItems.count == 10, "Should be 10 sample items")
      #expect(Item.sampleItems[0].name == "Morning Run")
      #expect(Item.sampleItems[1].itemDescription.contains("coffee"), "Second item's description includes 'coffee'")
      #expect(Item.sampleItems[0].config?.configName == "5K Run Reminder")
      print(Item.sampleItems.map { item in
        "\(item.name) has \(item.history.count) events"
      })

      // Event template count
      #expect(Event.sampleEvents.count == 10, "Should be 10 sample event templates")
      #expect(ItemConfig.sampleConfigs.count == 10, "Should be 10 sample configs")
      #expect(ItemConfig.sampleConfigs[0].configName == "5K Run Reminder")
      #expect(ItemConfig.sampleConfigs[1].reminding == false)

      #expect(Settings.sampleSettings.count == 2)
      #expect(Settings.sampleSettings[0].displayTimesUsing == .tenths)
      #expect(Settings.sampleSettings[1].displayTimesUsing == .subUnits)
    }


}
