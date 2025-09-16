import SwiftUI
import SwiftData

struct bMacRootView: View {
  @Environment(\.modelContext) private var modelContext

  // Selection is the live model reference, shared with child views
  @State private var selection: Item?
  @State private var showInspector: Bool = true

  // Keep a lightweight query of items for the sidebar/list
  @Query(sort: [SortDescriptor(\Item.lastModified, order: .reverse)])
  private var items: [Item]

  var body: some View {
    NavigationSplitView {
      ItemListView(selection: $selection)
    } detail: {
      if let sel = selection {
        // Pass a binding to ItemView and force rebuild when identity changes
        ItemView(item: $selection)
          .id(sel.id)
          .frame(minWidth: 420, minHeight: 320)
      } else {
        Text("Select an item")
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
#if os(macOS)
    .inspector(isPresented: $showInspector) {
      if let sel = selection {
        HistoryInspectorView(item: $selection)
          .id(sel.id)
          .frame(minWidth: 300, idealWidth: 340)
          .navigationTitle("History")
          .inspectorColumnWidth(min: 260, ideal: 340, max: 600)
      } else {
        Text("No item selected")
          .foregroundColor(.secondary)
          .frame(minWidth: 300, idealWidth: 340, maxHeight: .infinity)
      }
    }
#endif
  }
}

#Preview {
  bMacRootView()
    .modelContainer(ModelContainer.preview)
}
