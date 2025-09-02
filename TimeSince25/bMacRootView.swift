import SwiftUI
import SwiftData

struct bMacRootView: View {
  @Environment(\.modelContext) private var modelContext

  @State private var selection: Item?
  @State private var showInspector: Bool = true

  var body: some View {
    NavigationSplitView {
      ItemListView(selection: $selection)
    } detail: {
      if let _ = selection {
        ItemView(item: $selection)
          .frame(minWidth: 420, minHeight: 320)
      } else {
        Text("Select an item")
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
#if os(macOS)
    .inspector(isPresented: $showInspector) {
      HistoryInspectorView(item: $selection)
        .frame(minWidth: 300, idealWidth: 340)
        .navigationTitle("History")
        .inspectorColumnWidth(min: 260, ideal: 340, max: 600)
    }
#endif
  }
}

#Preview {
  bMacRootView()
    .modelContainer(ModelContainer.preview)
}
