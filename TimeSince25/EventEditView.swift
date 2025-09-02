import SwiftUI
import SwiftData

enum EventEditResult {
  case saved
  case deleted
  case cancelled
}

struct EventEditView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @State var timestamp: Date
  @State var valueText: String
  @State var notes: String

  let event: Event
  var onComplete: (EventEditResult) -> Void

  init(event: Event, onComplete: @escaping (EventEditResult) -> Void) {
    self.event = event
    self.onComplete = onComplete
    _timestamp = State(initialValue: event.timestamp)
    _valueText = State(initialValue: event.value.map { String($0) } ?? "")
    _notes = State(initialValue: event.notes ?? "")
  }

  var body: some View {
    NavigationStack {
      Form {
        DatePicker("Timestamp", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])

        Section(header: Text("Value")) {
          TextField("Enter a number (optional)", text: $valueText)
            .keyboardType(.decimalPad)
        }

        Section(header: Text("Notes")) {
          TextField("Notes (optional)", text: $notes, axis: .vertical)
            .lineLimit(3...6)
        }
      }
      .navigationTitle("Edit Event")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
            onComplete(.cancelled)
          }
        }
        ToolbarItem(placement: .destructiveAction) {
          Button(role: .destructive) {
            deleteEvent()
          } label: {
            Text("Delete")
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            saveEvent()
          }
        }
      }
    }
  }

  private func saveEvent() {
    event.timestamp = timestamp
    if let number = Double(valueText.trimmingCharacters(in: .whitespacesAndNewlines)), number.isFinite {
      event.value = number
    } else {
      event.value = nil
    }
    event.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
    // Update item's lastModified will be handled by parent on dismiss
    dismiss()
    onComplete(.saved)
  }

  private func deleteEvent() {
    // Remove from owning item
    if let idx = event.item.history.firstIndex(where: { $0 === event }) {
      event.item.history.remove(at: idx)
    }
    modelContext.delete(event)
    dismiss()
    onComplete(.deleted)
  }
}

#Preview {
  let item = Item(name: "Preview", itemDescription: "Demo")
  let ev = Event(item: item, timestamp: .now, value: 1.23, notes: "Hello")
  return EventEditView(event: ev) { _ in }
    .modelContainer(for: [Item.self, Event.self], inMemory: true)
}

