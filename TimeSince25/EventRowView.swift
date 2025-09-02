import SwiftUI
import SwiftData

struct EventRowView: View {
  let event: Event

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      VStack(alignment: .leading, spacing: 4) {
        Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
          .font(.body)
          .fontWeight(.semibold)
        if let notes = event.notes, !notes.isEmpty {
          Text(notes)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .lineLimit(2)
        }
      }
      Spacer()
      if let value = event.value {
        Text(formatValue(value))
          .font(.headline)
          .foregroundColor(.secondary)
      }
      Image(systemName: "chevron.right")
        .font(.subheadline)
        .foregroundColor(.accentColor)
    }
    .contentShape(Rectangle())
  }

  private func formatValue(_ value: Double) -> String {
    if value == floor(value) {
      return String(format: "%.0f", value)
    } else {
      return String(format: "%.2f", value)
    }
  }
}

#Preview {
  let item = Item(name: "Preview", itemDescription: "Demo")
  let event = Event(item: item, timestamp: .now, value: 12.34, notes: "Sample notes")
  return EventRowView(event: event)
    .padding()
}

