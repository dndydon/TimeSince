import SwiftUI
import SwiftData

enum EventEditResult {
  case saved
  case deleted
  case cancelled
}

@MainActor
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
            .applyKeyboard(.decimal)
        }

        Section(header: Text("Notes")) {
          TextField("Notes (optional)", text: $notes, axis: .vertical)
            .lineLimit(3...6)
        }
      }
      .navigationTitle("Event")
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

    let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
    event.notes = trimmedNotes.isEmpty ? nil : trimmedNotes

    // Keep the parent item’s lastModified fresh for sorting.
    event.item?.lastModified = .now

    dismiss()
    onComplete(.saved)
  }

  private func deleteEvent() {
    // Capture parent before deletion because the inverse may be cleared during delete.
    let parent = event.item

    // Delete the event; SwiftData will update the inverse relationship and parent array.
    modelContext.delete(event)

    // Update parent timestamp so sorting/UI remains consistent.
    parent?.lastModified = .now

    dismiss()
    onComplete(.deleted)
  }
}

#Preview {
  let item = Item(name: "Preview", itemDescription: "Demo")
  // Item() creates an initial event; use it for preview instead of adding a second one.
  let ev = item.history.first ?? Event(item: item, timestamp: .now, value: 1.23, notes: "Hello")
  return EventEditView(event: ev) { _ in }
    .modelContainer(for: [Item.self, Event.self], inMemory: true)
}

