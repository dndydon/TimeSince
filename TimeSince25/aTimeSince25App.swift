//
//  TimeSince25App.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/1/25.
//

import SwiftUI
import SwiftData

@main
struct aTimeSince25App: App {
  var sharedModelContainer: ModelContainer = {
    do {
      let schema = Schema([Item.self, Event.self, RemindConfig.self, Settings.self])
      let container = try ModelContainer(for: schema)
      return container
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      bMacRootView()
    }
    .modelContainer(sharedModelContainer)
  }
}

