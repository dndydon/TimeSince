# TimeSince25

A SwiftUI app that tracks events and shows how long it’s been since (or until) key moments, updating live with efficient time state. Built with Swift Data for persistence and designed to run great across Apple platforms.

- Platforms: iOS, iPadOS, macOS (SwiftUI, Swift Data)
- Minimum Xcode: 15+ (Swift 5.9+) — update as appropriate for your setup
- Data: Swift Data models (`Item`, `Event`, `RemindConfig`, `Settings`)
- Formatting: [DSRelativeTimeFormatter](https://github.com/donsleeter/DSRelativeTimeFormatter) for rich, multi-component relative time output

## Screenshots

> Placeholder for screenshots — add images when available
- Home view showing list of events and relative times
- Detail view with precise components (years • months • days • hours • minutes • seconds)
- Settings and reminder configuration

## Architecture Overview

The app follows a straightforward SwiftUI + Swift Data architecture:

- SwiftUI Scenes
  - `aTimeSince25App` is the entry point. It constructs a shared `ModelContainer` with a `Schema` including `Item`, `Event`, `RemindConfig`, and `Settings`, and injects it via `.modelContainer(...)`.
  - `bMacRootView` (and platform-specific root views as needed) composes the app’s primary UI.

- Swift Data Models (summary)
  - `Item`: Generic persisted entity used by list or sample content.
  - `Event`: The core domain model representing a date/time anchor (e.g., birthday, anniversary, deadline) with metadata and display configuration.
  - `RemindConfig`: User-configurable reminder rules (e.g., frequency, lead time) associated with one or more events.
  - `Settings`: App-wide preferences such as formatting options, default precision, and UI toggles.

- Business Logic
  - Event computation uses a lightweight time state publisher (see `.nowTick`) to drive live updates without heavy timers.
  - Relative time strings are produced with `DSRelativeTimeFormatter`, supporting decimal precision and multiple date components.
  - Persistence is powered by Swift Data with a single shared `ModelContainer`.

## Efficient Time Updates with `.nowTick`

To keep the UI responsive without wasting battery/CPU, the app uses a state property called `.nowTick` that advances at an interval appropriate for the current view’s precision. Key ideas:

1. Single Source of Truth
   - A single ticking `Date` value (e.g., `@State private var nowTick: Date = .now`) is updated by a lightweight `Timer` or Swift Concurrency `AsyncSequence` on a controlled cadence (e.g., every 1s on detail views that show seconds; every 30s–60s on list views that show minutes+). Views that display relative time bind to `nowTick` so SwiftUI re-renders only when needed.

2. Adaptive Cadence
   - Choose the interval based on what you display. If you show seconds, tick every second; if you show only minutes/hours/days, tick less often. This reduces wake-ups and improves battery life.

3. Coalesced Updates
   - Drive multiple cells/rows from the same `nowTick` rather than per-row timers. This avoids N timers and keeps scheduling overhead low.

Example pattern:

```swift
@State private var nowTick: Date = .now

var body: some View {
  List(events) { event in
    EventRow(event: event, now: nowTick)
  }
  .task { await startTicking(every: .seconds(1)) }
}

private func startTicking(every interval: Duration) async {
  for await _ in Timer.publish(every: interval.seconds, on: .main, in: .common).autoconnect().values {
    nowTick = .now
  }
}
