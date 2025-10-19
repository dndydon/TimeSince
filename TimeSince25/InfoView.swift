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

  // Single optional Settings instance (0 or 1); app ensures one exists at startup
  @Query private var _settingsFetch: [Settings]
  private var settings: Settings? { _settingsFetch.first }

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
          selectableRow(
            title: "Display times using tenths", subtitle: "example:  1.5 d ago",
            isSelected: settings?.displayTimesUsing == .tenths
          ) {
            if let s = settings {
              s.displayTimesUsing = .tenths
              do { try modelContext.save() } catch { /* handle error if desired */ }
            }
          }
          selectableRow(
            title: "Display times using sub-units", subtitle: "example:  1d 12hr ago",
            isSelected: settings?.displayTimesUsing == .subUnits
          ) {
            if let s = settings {
              s.displayTimesUsing = .subUnits
              do { try modelContext.save() } catch { /* handle error if desired */ }
            }
          }
        }

        // MARK: - Unit display (Settings)
        Section(header: Text("Display more details")) {
          Toggle(isOn: Binding(
            get: { settings?.showDetails ?? false },
            set: { newValue in
              if let s = settings {
                s.showDetails = newValue
                do { try modelContext.save() } catch { /* handle error if desired */ }
              }
            }
          )) {
            Text("Show second line of item info")
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
          Button {
            notImplemented("iCloud sync is not yet implemented.")
          } label: {
            HStack {
              Text("iCloud Synch")
              Spacer()
              Text("Disabled")
              Image(systemName: "chevron.right")
            }
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
      .alert("Not yet implemented", isPresented: $showNotImplementedAlert) {
        Button("OK", role: .cancel) { }
      } message: {
        Text(notImplementedMessage)
      }
      .sheet(isPresented: $showHelpSheet) {
        NavigationStack {
          HelpView()
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                  showHelpSheet = false
                }
              }
            }
        }
        //.presentationDetents([.medium, .large])
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
