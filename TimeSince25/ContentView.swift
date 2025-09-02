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
  @Query private var items: [Item]

  @State private var showingSettings = false
  //@State private var showingNewItem: Bool = false
  @State private var selectedItem: Item?

  var body: some View {
    NavigationStack {
      List {
        ForEach(items, id: \.name) { item in
          Button(action: { selectedItem = item }) {
            HStack {
              VStack(alignment: .leading) {
                Text(item.name)
                  .font(.headline)
                  .fontWeight(.heavy)

                if !item.itemDescription.isEmpty {
                  Text(item.itemDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }
              }
              Spacer()
              Image(systemName: "chevron.right")
            }
            .contentShape(Rectangle())
          }
        }
        .onDelete(perform: deleteItems)
      }
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
      .sheet(item: $selectedItem) { item in

        // Pass value, not binding, since `.sheet(item:)` closure provides a value, not a binding.
        ItemView(item: $selectedItem)
      }
    }
  }

  private func addItem() {
    withAnimation {
      let newItem = Item(
        name: UUID().uuidString,
        itemDescription: "New Item",
        history: [Event(timestamp: Date())],
        config: nil
      )
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
    //.modelContainer(for: Item.self, inMemory: true)
    .modelContainer(ModelContainer.preview)
}
