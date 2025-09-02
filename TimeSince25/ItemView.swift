// ItemView.swift
// For TimeSince25

import SwiftUI
import SwiftData

struct ItemView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @Binding var item: Item?

  // Sorting state: default to most recent first (descending)
  @State private var sortDescending: Bool = true

  // Event editing presentation
  @State private var selectedEvent: Event?
  @State private var showingEventEditor: Bool = false

  var body: some View {
    NavigationStack {
      Form {
        // MARK: - Basic Info
        Section(header: Text("Name")) {
          if let _ = item {
            TextField("Enter item name", text: Binding(
              get: { item?.name ?? "" },
              set: { newValue in
                item?.name = newValue
                touchLastModified()
              }
            ))
            .font(Font.custom("SF Pro Text", size: 22, relativeTo: .headline))
          } else {
            TextField("Enter item name", text: .constant(""))
              .disabled(true)
          }
        }

        Section(header: Text("Description")) {
          if let _ = item {
            TextField("Enter description", text: Binding(
              get: { item?.itemDescription ?? "" },
              set: { newValue in
                item?.itemDescription = newValue
                touchLastModified()
              }
            ))
          } else {
            TextField("Enter description", text: .constant(""))
              .disabled(true)
          }
        }

        // MARK: - Dates
        Section(header: Text("Dates")) {
          if let item {
            NavigationLink {
              DateEditView(
                title: "Created At",
                date: item.createdAt,
                onSave: { newDate in
                  item.createdAt = newDate
                  // Keep lastModified based on events primarily
                  recalcLastModifiedFromEvents()
                }
              )
            } label: {
              HStack {
                Text("Created At")
                Spacer()
                Text(item.createdAt.formatted(date: .numeric, time: .shortened))
                  .foregroundColor(.secondary)
              }
            }

            HStack {
              Text("Last Modified")
              Spacer()
              Text(item.lastModified.formatted(date: .numeric, time: .shortened))
                .foregroundColor(.secondary)
            }
          } else {
            HStack {
              Text("Created At")
              Spacer()
              Text("—").foregroundColor(.secondary)
            }
            HStack {
              Text("Last Modified")
              Spacer()
              Text("—").foregroundColor(.secondary)
            }
          }
        }

        // MARK: - Configuration
        Section(header: Text("Reminding")) {
          if let item {
            if let cfg = item.config {
              NavigationLink {
                ItemConfigEditView(item: item, config: cfg) { action in
                  switch action {
                  case .saved:
                    touchLastModified()
                  case .deleted:
                    // Remove association
                    item.config = nil
                    touchLastModified()
                  case .cancelled:
                    break
                  }
                }
              } label: {
                HStack {
                  VStack(alignment: .leading, spacing: 4) {
                    Text(cfg.configName)
                      .font(.headline)
                    HStack(spacing: 8) {
                      if cfg.reminding {
                        Image(systemName: "bell.fill")
                          .foregroundColor(.orange)
                        Text(cfg.remindAt.formatted(date: .abbreviated, time: .shortened))
                          .foregroundColor(.secondary)
                      } else {
                        Image(systemName: "bell.slash")
                          .foregroundColor(.secondary)
                        Text("Reminders off")
                          .foregroundColor(.secondary)
                      }
                    }
                    .font(.subheadline)
                  }
                }
              }
            } else {
              Button {
                // Create a default config and open editor
                let cfg = ItemConfig(
                  configName: "New Configuration",
                  reminding: false,
                  remindAt: .now,
                  remindInterval: 1,
                  timeUnits: .day
                )
                item.config = cfg
                touchLastModified()
              } label: {
                Label("Add Configuration", systemImage: "plus.circle")
              }
            }
          } else {
            Text("No item loaded")
              .foregroundColor(.secondary)
          }
        }

        // MARK: - History
        Section(header: historyHeader()) {
          if let sorted = sortedHistory(), !sorted.isEmpty {
            List {
              ForEach(sorted) { event in
                Button {
                  selectedEvent = event
                  showingEventEditor = true
                } label: {
                  EventRowView(event: event)
                }
                .buttonStyle(.plain)
              }
              .onDelete(perform: deleteEvents)
            }
          } else {
            Text("No history available")
              .foregroundColor(.secondary)
            Button("Add an Event") {
              addEvent()
            }
          }
        }
      }
      .navigationTitle("Item")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            saveItem()
          }
          .disabled(item?.name.trimmingCharacters(in: .whitespaces).isEmpty != false)
        }
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        //ToolbarItem(placement: .navigationBarTrailing) {
        //  if (item?.history.isEmpty == false) {
        //    EditButton()
        //  }
        //}
      }
      .onAppear {
        recalcLastModifiedFromEvents()
      }
      .sheet(isPresented: Binding(
        get: { showingEventEditor },
        set: { newVal in
          showingEventEditor = newVal
          if newVal == false {
            // ensure lastModified reflects latest event timestamp after dismissal
            recalcLastModifiedFromEvents()
          }
        })
      ) {
        if let event = selectedEvent {
          EventEditView(event: event) { action in
            switch action {
            case .saved:
              recalcLastModifiedFromEvents()
            case .deleted:
              selectedEvent = nil
              recalcLastModifiedFromEvents()
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
  }

  // MARK: - Header with sort toggle and add button

  private func historyHeader() -> some View {
    HStack {
      Button(action: { toggleSort() }) {
        HStack(spacing: 6) {
          Text("History")
            .font(.headline)
          Image(systemName: sortDescending ? "arrow.down" : "arrow.up")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .accessibilityLabel(sortDescending ? "Sorted newest first" : "Sorted oldest first")
        }
      }
      .buttonStyle(.plain)

      Spacer()

      // Use EditButton directly (it’s a View)
      EditButton()

      Button {
        addEvent()
      } label: {
        Label("Add Event", systemImage: "plus")
          .labelStyle(.iconOnly)
      }
      .buttonStyle(.automatic)
      .padding(.leading, 5)
    }
  }

  // MARK: - Helpers

  private func sortedHistory() -> [Event]? {
    guard let history = item?.history else { return nil }
    return history.sorted(by: { a, b in
      if sortDescending {
        return a.timestamp > b.timestamp
      } else {
        return a.timestamp < b.timestamp
      }
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
    guard let item else { return }
    let sorted = sortedHistory() ?? []
    let eventsToDelete = offsets.map { sorted[$0] }
    for ev in eventsToDelete {
      if let idx = item.history.firstIndex(where: { $0 === ev }) {
        item.history.remove(at: idx)
      }
      modelContext.delete(ev)
    }
    recalcLastModifiedFromEvents()
  }

  private func saveItem() {
    guard let item else { return }
    item.name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
    item.itemDescription = item.itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    recalcLastModifiedFromEvents()
    dismiss()
  }

  private func touchLastModified() {
    item?.lastModified = .now
  }

  private func recalcLastModifiedFromEvents() {
    guard let item else { return }
    if let newest = item.history.max(by: { $0.timestamp < $1.timestamp })?.timestamp {
      item.lastModified = newest
    } else {
      // If no events, keep lastModified at least createdAt
      item.lastModified = max(item.createdAt, item.lastModified)
    }
  }
}

#Preview {
  @Previewable @State var item: Item? = {
    let it = Item(
      name: "Sample Item",
      itemDescription: "A sample description",
      config: ItemConfig(configName: "Sample Config", reminding: true, remindAt: .now, remindInterval: 1, timeUnits: .day)
    )
    it.createEvent(timestamp: .now.addingTimeInterval(-3600), value: 3.2, notes: "Earlier")
    it.createEvent(timestamp: .now, value: 7.5, notes: "Latest")
    return it
  }()

  ItemView(item: $item)
    .modelContainer(for: [Item.self, Event.self, ItemConfig.self], inMemory: true)
}
