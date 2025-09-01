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

    var body: some View {
        NavigationStack {
            List {
                ForEach(items, id: \.name) { item in
                    NavigationLink(destination: Text(item.itemDescription)) {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            if !item.itemDescription.isEmpty {
                                Text(item.itemDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
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
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(name: UUID().uuidString, description: "New Item", config: nil)
            modelContext.insert(newItem)
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
        .modelContainer(for: Item.self, inMemory: true)
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Text("Settings go here")
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            // The sheet will be dismissed automatically
                        }
                    }
                }
        }
    }
}
