//
//  SettingsView.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/1/25.
//

import SwiftUI

struct SettingsView: View {
  var body: some View {
    NavigationStack {
      Text("Settings go here")
        .navigationTitle("Settings")
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button("Done") {
              // The sheet will be dismissed automatically
            }
          }
        }
    }
  }
}
