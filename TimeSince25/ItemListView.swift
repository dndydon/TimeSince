//
//  ItemListView.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/1/25.
//

import SwiftUI
import SwiftData
import Combine

struct ItemListView: View {
  @Environment(\.modelContext) private var modelContext

  // Default sort by last modified, newest first
  @Query(sort: [SortDescriptor(\Item.lastModified, order: .reverse)])
  private var items: [Item]

  // Fetch Settings internally; expose as a single optional.
  @Query private var _settingsFetch: [Settings]
  // Access the single Settings instance (first, created on demand in InfoView)
  private var settings: Settings? { _settingsFetch.first }

  // The selection is owned by the parent (split view); sidebar reads/writes it.
  @Binding var selection: Item?

  @State private var showingSettings = false

  // Shared clock driving dynamic updates (due highlighting and elapsed text)
  @State private var nowTick: Date = .now
  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  init(selection: Binding<Item?>) {
    self._selection = selection
  }

  var body: some View {
    // Determine the active display mode; default to .tenths if no row exists yet.
    let displayMode: DisplayTimesUsing = settings?.displayTimesUsing ?? .tenths

    List(selection: $selection) {
      ForEach(items) { item in

        ItemCellView(
          item: item,
          nowTick: nowTick,
          displayMode: displayMode, // .tenths or .subunits
          showDetails: settings?.showDetails ?? false,
          onLongPress: { pressedItem in
            // Provide haptic feedback (iOS) and animate the mutation so the row reorders with animation.
            performHapticForLongPress()
            var txn = Transaction()
            txn.animation = .easeOut(duration: 0.3)
            withTransaction(txn) {
              _ = pressedItem.createEvent(timestamp: .now)
              // createEvent updates lastModified; @Query sorts by lastModified desc, so this row moves to top.
            }
            do { try modelContext.save() } catch { /* handle or log error if needed */ }
          }
        )
          .tag(item) // keep tag for List(selection:)
          .contentShape(Rectangle()) // make the whole row tappable/clickable
          .onTapGesture {
            // Update split view selection so the detail shows
            selection = item
          }
          .accessibilityAddTraits(.isButton)
      }
      .onDelete(perform: deleteItems)
    }
    .animation(.easeOut(duration: 0.3), value: items)
#if os(iOS)
    .listStyle(.grouped)
    .navigationBarTitleDisplayMode(.inline)
#else
    .listStyle(.inset)
#endif
    .navigationTitle("Time Since")
    .toolbar {
#if os(iOS)
      // Leading: Info (question mark) to open settings/info sheet
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          showingSettings = true
        } label: {
          Label("Info", systemImage: "ellipsis")
        }
        .accessibilityLabel("Info")
      }

      // Trailing: Edit first (left-most), then Add
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        EditButton()
        Button(action: addItem) {
          Label("Add Item", systemImage: "plus")
        }
      }
#else
      // macOS toolbar placements (unchanged)
      ToolbarItem(placement: .navigation) {
        Button {
          showingSettings = true
        } label: {
          Label("Settings", systemImage: "gearshape")
        }
      }
      ToolbarItem(placement: .primaryAction) {
        Button(action: addItem) {
          Label("Add Item", systemImage: "plus")
        }
      }
#endif
    }
    .sheet(isPresented: $showingSettings) {
      InfoView()
    }
    // Drive periodic updates for due/highlight and elapsed text
    .onReceive(timer) { tick in
      nowTick = tick  // this should make ticks reactive updating.
    }
  }

  private func addItem() {
    withAnimation {
      let newName = uniqueDefaultName(base: "Untitled")
      let newItem = Item(
        name: newName,
        itemDescription: "",
        config: nil
      )
      // Item initializer already creates an initial event and default config.
      modelContext.insert(newItem)
      selection = newItem // select it in the split view
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        let item = items[index]
        if selection?.id == item.id {
          selection = nil
        }
        modelContext.delete(item)
        do { try modelContext.save() } catch { /* handle or log error if needed */ }
      }
    }
  }

  // Generate a unique name like "Untitled", "Untitled 2", ... ensuring store-wide uniqueness via SwiftData
  private func uniqueDefaultName(base: String) -> String {
    // First try the base name
    if (try? Item.exists(context: modelContext, name: base)) == false {
      return base
    }
    // Increment a suffix until we find a free name
    for n in 2...10_000 {
      let candidate = "\(base) \(n)"
      if (try? Item.exists(context: modelContext, name: candidate)) == false {
        return candidate
      }
    }
    // Fallback: timestamp-based unique name
    return "\(base) \(Int(Date().timeIntervalSince1970))"
  }

  // MARK: - Haptics

  private func performHapticForLongPress() {
#if os(iOS)
    // Prefer notification feedback to signal a successful action.
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
    // Alternatively, use impact:
    // let impact = UIImpactFeedbackGenerator(style: .medium)
    // impact.impactOccurred()
#endif
  }
}

#Preview {
  @Previewable @State var selection: Item? = nil
  return NavigationSplitView {
    ItemListView(selection: $selection)
  } detail: {
    if let sel = selection {
      ItemView(item: $selection)
        .id(sel.id) // ensure detail updates when selection changes
    } else {
      Text("Select an item")
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
  .modelContainer(ModelContainer.preview)
}
