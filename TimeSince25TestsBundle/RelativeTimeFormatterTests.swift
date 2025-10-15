import Foundation
import Testing
import DSRelativeTimeFormatter

@testable import TimeSince25

@MainActor
@Suite("DSRelativeTimeFormatter basic behavior")
struct RelativeTimeFormatterTests {

  let formatter = DSRelativeTimeFormatter()

  // Time unit helpers to keep expressions simple for the type-checker
  private let second: TimeInterval = 1
  private let minute: TimeInterval = 60
  private let hour: TimeInterval = 60 * 60
  private let day: TimeInterval = 24 * 60 * 60

  // Helper to create a pair (start, end) with a delta in seconds
  func range(delta: TimeInterval) -> (Date, Date) {
    let end = Date()
    let start = end.addingTimeInterval(-delta)
    return (start, end)
  }

  @Test("subunits: default two components hour + minute")
  func subunitsTwoComponentsHourMinute() async throws {
    let delta = 3 * hour + 12 * minute // 3h 12m
    let (start, end) = range(delta: delta)
    let s = formatter.subunits(from: start, to: end, components: 2)
    #expect(s == "3hr 12min ago")
  }

  @Test("subunits: single component hour")
  func subunitsSingleHour() async throws {
    let delta = 3 * hour // 3 hours
    let (start, end) = range(delta: delta)
    let s = formatter.subunits(from: start, to: end, components: 1)
    #expect(s == "3hr ago")
  }

  @Test("subunits: day + hour, drop minutes when limited to 2 components")
  func subunitsDayHour() async throws {
    let delta = 1 * day + 3 * hour + 30 * minute // 1d 3h 30m
    let (start, end) = range(delta: delta)
    let s = formatter.subunits(from: start, to: end, components: 2)
    #expect(s == "1d 3hr ago")
  }

  @Test("subunits: clamp to max 3 components")
  func subunitsClampTo3() async throws {
    let delta = 2 * day + 5 * hour + 7 * minute + 9 * second // 2d 5h 7m 9s
    let (start, end) = range(delta: delta)
    // Internally clamped to 3 components.
    let s = formatter.subunits(from: start, to: end, components: 3)
    #expect(s == "2d 5hr 7min ago")
  }

  @Test("subunits: zero duration -> 0s")
  func subunitsZero() async throws {
    let end = Date()
    let start = end
    let s = formatter.subunits(from: start, to: end, components: 2)
    #expect(s == "0s ago")
  }

  @Test("subunits: second boundary 59s -> 59s")
  func secondBoundary59() async throws {
    let delta = 59 * second
    let (start, end) = range(delta: delta)
    let s = formatter.subunits(from: start, to: end, components: 1)
    #expect(s == "59s ago")
  }

  @Test("subunits: minute boundary 60s -> 1min")
  func minuteBoundary60() async throws {
    let delta = 1 * minute
    let (start, end) = range(delta: delta)
    let s = formatter.subunits(from: start, to: end, components: 1)
    #expect(s == "1min ago")
  }

  @Test("subunits: 61s -> 1min 1s (two components)")
  func minutePlusOneSecond() async throws {
    let delta = 1 * minute + 1 * second
    let (start, end) = range(delta: delta)
    let s = formatter.subunits(from: start, to: end, components: 2)
    #expect(s == "1min 1s ago")
  }

  @Test("decimalMostSignificant: hours with one fraction digit")
  func decimalMostSignificantHours() async throws {
    let delta = 90 * minute // 1.5 hours
    let (start, end) = range(delta: delta)
    let s = formatter.decimalMostSignificant(from: start, to: end)
    #expect(s == "1.5 hr ago")
  }

  @Test("decimalMostSignificant: days rounding to one digit")
  func decimalMostSignificantDays() async throws {
    let delta = 2 * day + 0.34 * day // 2.34 days
    let (start, end) = range(delta: delta)
    let s = formatter.decimalMostSignificant(from: start, to: end)
    #expect(s == "2.3 d ago")
  }

  @Test("subunits: non-relative output")
  func subunitsNonRelative() async throws {
    let delta = 2 * minute + 5 * second // 2m 5s
    let (start, end) = range(delta: delta)
    let s = formatter.subunits(from: start, to: end, components: 2, showingRelative: false)
    #expect(s == "2min 5s")
  }
}

