import SwiftUI
import SwiftData

struct HistoryInspectorView: View {
  @Environment(\.modelContext) private var modelContext

  @Binding var item: Item?

  // Sorting state: default to most recent first (descending)
  @State private var sortDescending: Bool = true

  // Event editing presentation
  @State private var selectedEvent: Event?
  @State private var showingEventEditor: Bool = false

  var body: some View {
    VStack(spacing: 0) {
      header()

      if let sorted = sortedHistory(), !sorted.isEmpty {
        List {
          ForEach(sorted) { event in
            Button {
              selectedEvent = event
              showingEventEditor = true
            } label: {
              EventRow(event: event)
            }
            .buttonStyle(.plain)
          }
          .onDelete(perform: deleteEvents)
        }
        .listStyle(.inset)
      } else {
        VStack(spacing: 12) {
          Text("No history available")
            .foregroundColor(.secondary)
          Button {
            addEvent()
          } label: {
            Label("Add Event", systemImage: "plus")
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .sheet(isPresented: $showingEventEditor) {
      if let ev = selectedEvent {
        EventEditView(event: ev) { action in
          switch action {
          case .saved, .deleted:
            recalcLastModifiedFromEvents()
            if case .deleted = action {
              selectedEvent = nil
            }
          case .cancelled:
            break
          }
        }
      } else {
        Text("No event selected")
          .padding()
      }
    }
  }

  // MARK: - Header

  private func header() -> some View {
    HStack {
      Button(action: { toggleSort() }) {
        HStack(spacing: 8) {
          Text("History")
          Image(systemName: sortDescending ? "arrow.down" : "arrow.up")
            .foregroundColor(.accentColor)
            .accessibilityLabel(sortDescending ? "Sorted newest first" : "Sorted oldest first")
        }
      }
      .buttonStyle(.plain)

      Spacer()

      Button {
        addEvent()
      } label: {
        Label("Add Event", systemImage: "plus")
          .labelStyle(.iconOnly)
      }
      .buttonStyle(.automatic)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
  }

  // MARK: - Helpers

  private func sortedHistory() -> [Event]? {
    guard let history = item?.history else { return nil }
    return history.sorted(by: { a, b in
      sortDescending ? (a.timestamp > b.timestamp) : (a.timestamp < b.timestamp)
    })
  }

  private func toggleSort() {
    withAnimation {
      sortDescending.toggle()
    }
  }

  private func addEvent() {
    guard let item else { return }
    let event = item.createEvent(timestamp: .now)
    recalcLastModifiedFromEvents()
    selectedEvent = event
    showingEventEditor = true
  }

  private func deleteEvents(at offsets: IndexSet) {
    guard item != nil else { return }
    let sorted = sortedHistory() ?? []
    let eventsToDelete = offsets.map { sorted[$0] }
    for ev in eventsToDelete {
      modelContext.delete(ev)
    }
    recalcLastModifiedFromEvents()
  }

  private func recalcLastModifiedFromEvents() {
    guard let item else { return }
    if let newest = item.history.max(by: { $0.timestamp < $1.timestamp })?.timestamp {
      item.lastModified = newest
    } else {
      item.lastModified = max(item.createdAt, item.lastModified)
    }
  }
}

// A minimal row for events in the inspector.
// If you already have EventRowView or similar, replace this with it.
private struct EventRow: View {
  let event: Event

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      VStack(alignment: .leading, spacing: 4) {
        Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
          .font(.headline)
        if let value = event.value {
          Text("\(value)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        if let notes = event.notes, !notes.isEmpty {
          Text(notes)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .lineLimit(2)
        }
      }
      Spacer()
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  @Previewable @State var item: Item? = {
    let it = Item(
      name: "Sample",
      itemDescription: "Demo",
      config: nil
    )
    it.createEvent(timestamp: .now.addingTimeInterval(-3600), value: 3.2, notes: "Earlier")
    it.createEvent(timestamp: .now, value: 7.5, notes: "Latest")
    return it
  }()

  return HistoryInspectorView(item: $item)
    .frame(width: 340, height: 480)
    .modelContainer(ModelContainer.preview)
}
