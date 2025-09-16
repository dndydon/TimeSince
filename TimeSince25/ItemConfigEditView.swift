import SwiftUI
import SwiftData

enum ItemConfigEditResult {
  case saved
  case deleted
  case cancelled
}

struct ItemConfigEditView: View {
  @Environment(\.dismiss) private var dismiss

  // Editing a specific item's config to allow delete to detach from item
  let item: Item
  let config: ItemConfig

  @State private var reminding: Bool
  @State private var remindAt: Date
  @State private var remindIntervalText: String
  @State private var timeUnits: Units

  var onComplete: (ItemConfigEditResult) -> Void

  init(item: Item, config: ItemConfig, onComplete: @escaping (ItemConfigEditResult) -> Void) {
    self.item = item
    self.config = config
    self.onComplete = onComplete
    _reminding = State(initialValue: config.reminding)
    // Default to "now" on open, per request
    _remindAt = State(initialValue: .now)
    _remindIntervalText = State(initialValue: String(config.remindInterval))
    _timeUnits = State(initialValue: config.timeUnits)
  }

  var body: some View {
    Form {
      Section(header: Text("Reminders")) {
        Toggle("Reminding", isOn: $reminding)
        DatePicker("Remind At", selection: $remindAt, displayedComponents: [.hourAndMinute])
          .disabled(!reminding)

        HStack {
          Text("Interval")
          Spacer()
          TextField("Interval", text: $remindIntervalText)
            .applyKeyboard(.number)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: 80)
        }

        Picker("Units", selection: $timeUnits) {
          Text("Minutes").tag(Units.minute)
          Text("Hours").tag(Units.hour)
          Text("Days").tag(Units.day)
          Text("Weeks").tag(Units.week)
          Text("Months").tag(Units.month)
          Text("Years").tag(Units.year)
        }
      }

      Section {
        Button(role: .destructive) {
          deleteConfig()
        } label: {
          Text("Delete Configuration")
        }
      }
    }
    .navigationTitle("Item Configuration")
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
          onComplete(.cancelled)
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button("Save") {
          saveConfig()
        }
      }
    }
  }

  private func saveConfig() {
    config.reminding = reminding
    config.remindAt = remindAt
    if let interval = Int(remindIntervalText.trimmingCharacters(in: .whitespacesAndNewlines)), interval > 0 {
      config.remindInterval = interval
    }
    config.timeUnits = timeUnits

    // Keep the parent item’s lastModified fresh for sorting and UI.
    item.lastModified = .now

    dismiss()
    onComplete(.saved)
  }

  private func deleteConfig() {
    // Detach from item; keep object around or delete? Here we detach.
    item.config = nil

    // Update the parent item’s lastModified to reflect the change.
    item.lastModified = .now

    dismiss()
    onComplete(.deleted)
  }
}

#Preview {
  let item = Item(name: "Preview", itemDescription: "Demo")
  let cfg = ItemConfig(configName: "Config", reminding: true, remindAt: .now, remindInterval: 2, timeUnits: .day)
  item.config = cfg
  return NavigationStack {
    ItemConfigEditView(item: item, config: cfg) { _ in }
  }
}
