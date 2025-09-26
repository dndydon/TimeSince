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

  // Force list refresh when events are saved/deleted from the sheet
  @State private var historyVersion: Int = 0

  // Focus handling for text selection
  private enum FocusedField: Hashable {
    case name, description
  }
  @FocusState private var focusedField: FocusedField?

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
            .focused($focusedField, equals: .name)
            .selectAllOnFocus(when: focusedField == .name)
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
            .focused($focusedField, equals: .description)
            .selectAllOnFocus(when: focusedField == .description)
          } else {
            TextField("Enter description", text: .constant(""))
              .disabled(true)
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
                  Text(RemindLogic.reminderSummary(config: cfg))
                    .font(.headline)
                  Spacer()
                  Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                }
              }
            } else {
              Button {
                // Create a default config and open editor
                let cfg = ItemConfig(
                  configName: "New Reminder",
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
            ForEach(sorted, id: \.id) { event in
              Button {
                selectedEvent = event
                showingEventEditor = true
              } label: {
                EventRowView(event: event)
              }
              .buttonStyle(.plain)
            }
            .onDelete(perform: deleteEvents)
            .animation(.snappy, value: historyVersion)
          } else {
            Text("No history available")
              .foregroundColor(.secondary)
            Button("Add an Event") {
              addEvent()
            }
          }
        }
      }
      .navigationTitle(item?.name ?? "Item")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            saveItem()
          }
          .disabled(item?.name.trimmingCharacters(in: .whitespaces).isEmpty != false)
        }
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
            // Force a refresh even when lastModified didn’t change
            historyVersion &+= 1
          }
        })
      ) {
        if let event = selectedEvent {
          EventEditView(event: event) { action in
            switch action {
            case .saved:
              recalcLastModifiedFromEvents()
              historyVersion &+= 1
            case .deleted:
              selectedEvent = nil
              recalcLastModifiedFromEvents()
              historyVersion &+= 1
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
        HStack(spacing: 9) {
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
  }

  // MARK: - Helpers

  private func sortedHistory() -> [Event]? {
    guard let history = item?.history else { return nil }
    // Touch historyVersion so SwiftUI knows to recompute when it changes
    _ = historyVersion
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
    do { try modelContext.save() } catch { /* handle or log error if needed */ }
    historyVersion &+= 1
    selectedEvent = event
    showingEventEditor = true
  }

  private func deleteEvents(at offsets: IndexSet) {
    guard item != nil else { return }
    withAnimation {
      let sorted = sortedHistory() ?? []
      let eventsToDelete = offsets.map { sorted[$0] }
      for ev in eventsToDelete {
        modelContext.delete(ev)
      }
      recalcLastModifiedFromEvents()
      do { try modelContext.save() } catch { /* handle or log error if needed */ }
      historyVersion &+= 1
    }
  }

  private func saveItem() {
    guard let item else { return }
    item.name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
    item.itemDescription = item.itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    recalcLastModifiedFromEvents()
    do { try modelContext.save() } catch { /* handle or log error if needed */ }
    dismiss()
  }

  private func touchLastModified() {
    item?.lastModified = .now
    do { try modelContext.save() } catch { /* handle or log error if needed */ }
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

#if os(iOS) || os(tvOS)
import UIKit

private extension UIView {
  var firstResponder: UIResponder? {
    if isFirstResponder { return self }
    for sub in subviews {
      if let r = sub.firstResponder { return r }
    }
    return nil
  }
}
#elseif os(macOS)
import AppKit
#endif

private struct SelectAllOnFocusModifier: ViewModifier {
  @State private var armed: Bool = false
  let condition: Bool

  func body(content: Content) -> some View {
    content
      .background(SelectionPerformer(armed: $armed))
      .onChange(of: condition) { _, newValue in
        if newValue {
          armed = true
        }
      }
  }

#if os(iOS) || os(tvOS)
  private struct SelectionPerformer: UIViewRepresentable {
    @Binding var armed: Bool

    func makeUIView(context: Context) -> UIView { UIView(frame: .zero) }

    func updateUIView(_ uiView: UIView, context: Context) {
      guard armed else { return }
      DispatchQueue.main.async {
        armed = false
        guard let responder = uiView.window?.firstResponder else { return }
        if let tf = responder as? UITextField {
          tf.selectAll(nil)
        } else if let tv = responder as? UITextView {
          tv.selectAll(nil)
        }
      }
    }
  }
#elseif os(macOS)
  private struct SelectionPerformer: NSViewRepresentable {
    @Binding var armed: Bool

    func makeNSView(context: Context) -> NSView { NSView(frame: .zero) }

    func updateNSView(_ nsView: NSView, context: Context) {
      guard armed else { return }
      DispatchQueue.main.async {
        armed = false
        guard let fieldEditor = nsView.window?.firstResponder as? NSTextView else { return }
        fieldEditor.selectAll(nil)
      }
    }
  }
#endif
}

private extension View {
  func selectAllOnFocus(when condition: Bool) -> some View {
    modifier(SelectAllOnFocusModifier(condition: condition))
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

