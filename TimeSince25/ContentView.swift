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
        ForEach(items, id: \.name) { item in
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
//                if !item.itemDescription.isEmpty {
//                  Text(item.itemDescription)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//                }
              }
              //Spacer()
              //Image(systemName: "chevron.right")
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
      let newItem = Item(
        name: UUID().uuidString,
        itemDescription: "New Item",
        config: nil
      )
      // Create an initial event linked to this item
      newItem.createEvent(timestamp: .now)
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
}

#Preview {
  ContentView()
    .modelContainer(ModelContainer.preview)
}
