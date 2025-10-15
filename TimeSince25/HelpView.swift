import SwiftUI

struct HelpView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        Text("Overview")
          .font(.title2)
        Text("TimeSince is a simple, customizable way to keep notes of when things happened or need to happen. It's a logbook of your life’s events.")
        Text("Track the Time Since events happened, like a logbook for your life.")
        Text("Often, you want to know how long it has been since an event happened. If you want to do something regularly, set a reminder period for it. Some events repeat, some don't. You can also set a custom date for an event, past or future.")
        Text("Examples:\n- Every day at 4pm do XYZ. \n- Log when you do XYZ. \n- Log if/when you took your medicine.")

        Text("Tips")
          .font(.title2)
        Text("• Use the + button to add a new Untitled item.\n• Tap an item to change its name, date and how often it should be recur.\n• Tap an item to edit items and view events.\n• Swipe left or right to delete an item or event.")

        Text("Support")
          .font(.title2)
        Text("For feedback or bug reports, use the Send Feedback option.")
      }
      .navigationTitle("TimeSince")
      .padding()
    }
  }
}

#Preview {
  NavigationStack { HelpView() }
}
