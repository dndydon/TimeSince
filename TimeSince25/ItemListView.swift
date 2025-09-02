//
//  ItemListView.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/1/25.
//

import SwiftUI
import SwiftData

struct ItemListView: View {
  @Environment(\.modelContext) private var modelContext

  // Default sort by last modified, newest first
  @Query(sort: [SortDescriptor(\Item.lastModified, order: .reverse)])
  private var items: [Item]

  // The selection is owned by the parent (split view); sidebar reads/writes it.
  @Binding var selection: Item?

  @State private var showingSettings = false

  init(selection: Binding<Item?>) {
    self._selection = selection
  }

  var body: some View {
    List(selection: $selection) {
      ForEach(items) { item in
        HStack {
          VStack(alignment: .leading) {
            HStack {
              Text(item.name)
                .font(.headline)
                .fontWeight(.heavy)
              Spacer()
              Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
            }
            let dateString = item.lastModified.formatted(date: .abbreviated, time: .standard)
            Text(dateString)
              .font(.subheadline)
              .foregroundColor(.secondary)
              .lineLimit(1)
          }
        }
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
#if os(iOS)
    .listStyle(.grouped)
#else
    .listStyle(.inset)
#endif
    .navigationTitle("Items")
    .toolbar {
#if os(iOS)
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          showingSettings = true
        } label: {
          Label("Settings", systemImage: "gearshape")
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        EditButton()
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: addItem) {
          Label("Add Item", systemImage: "plus")
        }
      }
#else
      // macOS toolbar placements
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
      SettingsView()
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
      // Item initializer already creates an initial event.
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
      }
    }
  }

  // Generate a unique name like "Untitled", "Untitled 2", "Untitled 3", ...
  private func uniqueDefaultName(base: String) -> String {
    let existingNames = Set(items.map { $0.name })
    if !existingNames.contains(base) {
      return base
    }
    // Try a reasonable range, then fall back to a timestamp to guarantee a return.
    for n in 2...10_000 {
      let candidate = "\(base) \(n)"
      if !existingNames.contains(candidate) {
        return candidate
      }
    }
    return "\(base) \(Int(Date().timeIntervalSince1970))"
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

