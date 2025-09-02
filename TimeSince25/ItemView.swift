// ItemView.swift
// For TimeSince25

import SwiftUI
import SwiftData

struct ItemView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @Binding var item: Item?

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("Name")) {
          if let _ = item {
            TextField("Enter item name", text: Binding(
              get: { item?.name ?? "" },
              set: { newValue in item?.name = newValue }
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
              set: { newValue in item?.itemDescription = newValue }
            ))
          } else {
            TextField("Enter description", text: .constant(""))
              .disabled(true)
          }
        }
        Section(header: Text("History")) {
          if let history = item?.history, !history.isEmpty {
            List(history, id: \.timestamp) { event in
              Text(event.timestamp.formatted())
            }
          } else {
            Text("No history available")
              .foregroundColor(.secondary)
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
      }
    }
  }

  private func saveItem() {
    guard let item else { return }
    let newItem = Item(
      name: item.name.trimmingCharacters(in: .whitespaces),
      itemDescription: item.itemDescription.trimmingCharacters(in: .whitespaces),
      history: item.history,
      config: nil
    )
    modelContext.insert(newItem)
    dismiss()
  }
}

#Preview {
  @Previewable @State var item: Item? = Item(
    name: "Sample Item",
    itemDescription: "A sample description",
    history: [Event.sampleEvents.first!],
    config: nil
  )

  ItemView(item: $item)
    .modelContainer(for: Item.self, inMemory: true)
}
