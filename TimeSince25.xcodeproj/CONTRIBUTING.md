# Contributing to TimeSince25

Thanks for your interest in contributing! This guide explains how to get set up, the development workflow, and how to submit changes. If you’re new to open source or GitHub, don’t worry — start small and feel free to open a draft PR to ask questions.

## Code of Conduct

Be kind, respectful, and constructive. We’re here to build something useful together. Harassment, discrimination, or disrespectful behavior isn’t tolerated.

## Getting Started

1. Fork the repository and clone your fork.
2. Open the project in Xcode.
3. Add the `DSRelativeTimeFormatter` package if Xcode prompts you (File > Add Packages… → `https://github.com/donsleeter/DSRelativeTimeFormatter`).
4. Build and run the app on iOS, iPadOS, or macOS.

## Development Workflow

- Create a feature branch from `main`:
  - `git checkout -b feature/short-description`
- Keep your branch focused. Small, incremental changes are easier to review.
- Write clear commit messages (imperative mood):
  - `Add EventRow showing multi-component relative time`
- Add tests when fixing bugs or adding features.
- Run the test suite before pushing.

## Coding Style

- Prefer Swift Concurrency (async/await) where appropriate.
- Keep views small and composable.
- Avoid per-row timers; prefer shared `.nowTick` updates.
- Use `DSRelativeTimeFormatter` consistently for relative time output.
- Prefer dependency injection for formatters and clocks in testable code.

## Submitting Changes

1. Push your branch to your fork.
2. Open a Pull Request (PR) against `main` with:
   - A clear description of the problem and the solution.
   - Screenshots or screen recordings if the UI changed.
   - Notes on performance or battery impact if relevant.
3. Mark the PR as “Draft” if you want early feedback.

## Issue Reporting

- Use the issue templates (coming soon) to file bugs and feature requests.
- For bugs, include steps to reproduce, expected vs actual behavior, and device/OS details.

## Testing

- Use the Swift Testing framework for unit tests (Xcode 15+).
- Prefer deterministic tests: inject a test clock and fixed dates.
- Add coverage for:
  - Relative time formatting edge cases (DST, leap years, future vs past)
  - `.nowTick` cadence logic
  - Swift Data persistence (in-memory containers for tests)

## Roadmap Areas Open for Contribution

- iCloud sync (CloudKit-backed Swift Data)
- Schema evolution/migrations
- Help/FAQ content and in-app help UI
- Feedback via Mail compose with prefilled templates
- Minimal support website scaffolding
- Item editor enhancements

Thanks again for helping make TimeSince25 better!
