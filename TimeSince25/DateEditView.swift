import SwiftUI

struct DateEditView: View {
  let title: String
  @State var date: Date
  var onSave: (Date) -> Void

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    Form {
      DatePicker(title, selection: $date, displayedComponents: [.date, .hourAndMinute])
        .datePickerStyle(.graphical)
    }
    .navigationTitle(title)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button("Save") {
          onSave(date)
          dismiss()
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    DateEditView(title: "Created At", date: .now) { _ in }
  }
}

