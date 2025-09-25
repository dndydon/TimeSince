//
//  InfoView.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/1/25.
//

import SwiftUI
import SwiftData

struct InfoView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  // Fetch Settings rows; we will ensure there is exactly one active instance.
  @Query private var settingsRows: [Settings]

  @State private var activeSettings: Settings?
  @State private var showHelpSheet: Bool = false
  @State private var showNotImplementedAlert: Bool = false
  @State private var notImplementedMessage: String = ""

  var body: some View {
    NavigationStack {
      Form {
        // MARK: - Help
        Section {
          Button {
            showHelpSheet = true
          } label: {
            HStack {
              Text("Help")
              Spacer()
              Image(systemName: "chevron.right")
                //.foregroundColor(.secondary)
            }
          }
        }

        // MARK: - Export
        Section {
          Button {
            // Stub only: show a message; actual export/mail will come later.
            notImplemented("Export data is not yet implemented.")
          } label: {
            HStack {
              Text("Export, share, or backup your data")
              Spacer()
              Image(systemName: "chevron.right")
            }
          }
        }

        // MARK: - Unit display (Settings)
        Section(header: Text("Unit display")) {
          if let s = activeSettings {
            selectableRow(
              title: "Display times using tenths", subtitle: "e.g. 1.5 days ago",
              isSelected: s.displayTimesUsing == .tenths
            ) {
              s.displayTimesUsing = .tenths
            }
            selectableRow(
              title: "Display times using sub-units", subtitle: "e.g. 1 day 12 hrs ago",
              isSelected: s.displayTimesUsing == .subUnits
            ) {
              s.displayTimesUsing = .subUnits
            }
          } else {
            Text("Loading settings…").foregroundColor(.secondary)
          }
        }

        // MARK: - Support
        Section(header: Text("Support")) {
          Button {
            notImplemented("Mail comment or bug report is not yet implemented.")
          } label: {
            HStack {
              Text("Mail comment or bug report")
              Spacer()
              Image(systemName: "chevron.right")
            }
          }

          Button {
            notImplemented("Visit support website is not yet implemented.")
          } label: {
            HStack {
              Text("Visit support website")
              Spacer()
              Image(systemName: "chevron.right")
            }
          }
        }

        // MARK: - Version footer
        Section {
          HStack {
            Text("Version")
            Spacer()
            Text(appVersionString())
              .foregroundColor(.secondary)
          }
        }
      }
      .navigationTitle("Settings")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .onAppear {
        ensureSingleSettings()
      }
      .alert("Not yet implemented", isPresented: $showNotImplementedAlert) {
        Button("OK", role: .cancel) { }
      } message: {
        Text(notImplementedMessage)
      }
      .sheet(isPresented: $showHelpSheet) {
        NavigationStack {
          Form {
            Section {
              Text("Help content goes here.")
                .foregroundColor(.secondary)
            }
          }
          .navigationTitle("Help")
          .toolbar {
            ToolbarItem(placement: .primaryAction) {
              Button("Done") {
                showHelpSheet = false
              }
            }
          }
        }
        .presentationDetents([.medium, .large])
      }
    }
  }

  // MARK: - Helpers

  private func selectableRow(
    title: String, subtitle: String? = nil,
    isSelected: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      HStack {
        VStack(alignment: .leading) {
          Text(title)
            .foregroundColor(.primary)
          Text(subtitle ?? "")
          .font(Font.caption.bold())
          .foregroundStyle(Color.secondary)
        }
        Spacer()
        if isSelected {
          Image(systemName: "checkmark")
            .foregroundColor(.accentColor)
        }
      }
    }
  }

  private func notImplemented(_ message: String) {
    notImplementedMessage = message
    showNotImplementedAlert = true
  }

  private func ensureSingleSettings() {
    if let existing = settingsRows.first {
      activeSettings = existing
    } else {
      // Create one with defaults
      let s = Settings(displayTimesUsing: .tenths)
      modelContext.insert(s)
      activeSettings = s
    }
    // If multiple exist (e.g., from previews), we simply use the first.
    // You can add a migration to clean them up later if desired.
  }

  private func appVersionString() -> String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    return "\(version) (\(build))"
  }
}

#Preview {
  NavigationStack {
    InfoView()
  }
  .modelContainer(ModelContainer.preview)
}
