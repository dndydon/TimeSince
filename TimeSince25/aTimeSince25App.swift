//
//  TimeSince25App.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/1/25.
//

import SwiftUI
import SwiftData

/// enabling CloudKit:
/// • Enable iCloud + CloudKit in the target’s Signing & Capabilities.
/// • Uncomment the CloudKit block, below, in init() and rebuild.
/// • We can then add basic diagnostics and tests to verify sync.

@main
struct aTimeSince25App: App {

  let sharedModelContainer: ModelContainer

  init() {
    let schema = Schema([Item.self, Event.self, RemindConfig.self, Settings.self])
    do {
      self.sharedModelContainer = try ModelContainer(for: schema)
    } catch {
      fatalError("Could not create local ModelContainer: \(error)")
    }

    // To enable CloudKit later:
    // do {
    //   let config = ModelConfiguration(
    //     schema: schema,
    //     isStoredInMemoryOnly: false,
    //     cloudKitDatabase: .automatic // or .private / .public
    //   )
    //   self.sharedModelContainer = try ModelContainer(for: schema, configurations: [config])
    // } catch {
    //   fatalError("Could not create CloudKit ModelContainer: \(error)")
    // }
  }

  var body: some Scene {
    WindowGroup {
      bMacRootView()
    }
    .modelContainer(sharedModelContainer)
  }
}
