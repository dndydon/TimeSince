import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("TimeSince25 Help")
                    .font(.largeTitle)
                    .bold()

                Text("Overview")
                    .font(.title2)
                Text("Track events and see how long it’s been since (or until) important moments. Use Settings to customize formatting and reminders.")

                Text("Tips")
                    .font(.title2)
                Text("• Tap an event to view precise components.\n• Use the + button to add a new event.\n• Adjust precision and units in Settings.")

                Text("Support")
                    .font(.title2)
                Text("For feedback or bug reports, use the Send Feedback option.")
            }
            .padding()
        }
        .navigationTitle("Help")
    }
}

#Preview {
    NavigationStack { HelpView() }
}
