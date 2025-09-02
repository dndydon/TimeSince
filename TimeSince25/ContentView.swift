//
//  ContentView.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext

  // You can add sort descriptors once you decide the default sort (e.g., by name or lastModified)
  @Query(sort: [SortDescriptor(\Item.lastModified, order: .reverse)])
  private var items: [Item]

  @State private var showingSettings = false
  @State private var selectedItem: Item?

  var body: some View {
    NavigationStack {
      List {
        ForEach(items) { item in
          Button(action: { selectedItem = item }) {
            HStack {
              VStack(alignment: .leading) {
                HStack {
                  Text(item.name)
                    .font(.headline)
                    .fontWeight(.heavy)
                  Spacer()
                  Image(systemName: "chevron.right")
                }
                let dateString = item.lastModified.formatted(date: .abbreviated, time: .standard)
                Text(dateString)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .lineLimit(1)
              }
            }
            .contentShape(Rectangle())
          }
        }
        .onDelete(perform: deleteItems)
      }
      .listStyle(.grouped)
      .navigationTitle("Items")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            showingSettings = true
          } label: {
            Label("Settings", systemImage: "gearshape")
          }
        }
#if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
#endif
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      .sheet(isPresented: $showingSettings) {
        SettingsView()
      }
      .sheet(item: $selectedItem) { _ in
        // Pass the binding so the view can edit the selected item
        ItemView(item: $selectedItem)
      }
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
      selectedItem = newItem // Present sheet for new item
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
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
  ContentView()
    .modelContainer(ModelContainer.preview)
}
