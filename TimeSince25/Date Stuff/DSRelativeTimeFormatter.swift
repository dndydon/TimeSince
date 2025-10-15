//
//  DSRelativeTimeFormatter.swift
//  Shared Utilities
//
//  A small, reusable formatter for relative time strings.
//  Import into any app or package that needs concise, human-friendly
//  elapsed time strings.
//
//  This type is immutable and thread-safe.
//

import Foundation

/// A lightweight formatter that converts date intervals into concise strings.
///
/// The formatter provides two styles:
/// - `subunits`: Picks one or more best-fitting units (s, min, hr, d, wk, mo, yr) and shows integer quantities.
///   Example: "3hr 15min ago", "1d 3hr ago", "45s".
/// - `decimalMostSignificant`: Picks the most significant unit and shows one fractional digit.
///   Example: "1.5 hr ago", "2.3 d".
///
/// Usage:
/// ```swift
/// let formatter = DSRelativeTimeFormatter()
/// let start = someDate
/// let end = Date()
/// let s1 = formatter.subunits(from: start, to: end, components: 2)  // "3hr 15min ago"
/// let s2 = formatter.decimalMostSignificant(from: start, to: end)    // "1.5 hr ago"
/// ```
public struct DSRelativeTimeFormatter {
  /// Create a formatter. This type is stateless and thread-safe.
  public init() {}

  /// Returns a compact string using one or more abbreviated subunits with integer quantities.
  /// - Parameters:
  ///   - start: The earlier date (anchor).
  ///   - to: The later date (usually now).
  ///   - components: The number of components to include (e.g., `2` -> "1d 3hr"). Defaults to `2`.
  ///   - showingRelative: If `true`, appends " ago" to indicate past time.
  /// - Returns: A string like "3hr 15min ago", "1d 3hr ago", or "45s".
  public func subunits(from start: Date, to end: Date, components: Int = 2, showingRelative: Bool = true) -> String {
    let duration = max(0, end.timeIntervalSince(start))
    var remaining = duration

    // Clamp components to a safe range (1...3) to keep strings concise by default
    let maxComponents = max(1, min(components, 3))

    // Ordered from largest to smallest using our approximate standardTimeInterval values
    let orderedUnits: [Calendar.Component] = [.year, .month, .weekOfYear, .day, .hour, .minute, .second]

    var parts: [String] = []

    for unit in orderedUnits {
      guard let seconds = unit.standardTimeInterval() else { continue }
      if remaining >= seconds || (unit == .second && parts.isEmpty) {
        let value = Int(remaining / seconds)
        if value > 0 || parts.isEmpty { // ensure at least one component
          parts.append("\(value)\(shortSymbol(for: unit))")
          remaining -= TimeInterval(value) * seconds
        }
      }
      if parts.count == maxComponents { break }
    }

    let core = parts.joined(separator: " ")
    return showingRelative ? core + " ago" : core
  }

  /// Returns a compact string using the most significant unit with one fractional digit.
  /// - Parameters:
  ///   - start: The earlier date (anchor).
  ///   - to: The later date (usually now).
  ///   - showingRelative: If `true`, appends " ago" to indicate past time.
  /// - Returns: A string like "1.5 hr ago" or "2.3 d".
  public func decimalMostSignificant(from start: Date, to end: Date, showingRelative: Bool = true) -> String {
    let duration = max(0, end.timeIntervalSince(start))
    let unit = mostSignificantUnit(for: duration)
    let unitSeconds = unit.standardTimeInterval() ?? 1
    let decimal = duration / unitSeconds
    let formatted = Self.oneFractionDigit(decimal)
    let symbol = shortSymbol(for: unit)
    let core = "\(formatted) \(symbol)"
    return showingRelative ? core + " ago" : core
  }

  // MARK: - Helpers

  private func mostSignificantUnit(for duration: TimeInterval) -> Calendar.Component {
    // From largest to smallest
    if let year = Calendar.Component.year.standardTimeInterval(), duration >= year { return .year }
    if let month = Calendar.Component.month.standardTimeInterval(), duration >= month { return .month }
    if let week = Calendar.Component.weekOfYear.standardTimeInterval(), duration >= week { return .weekOfYear }
    if let day = Calendar.Component.day.standardTimeInterval(), duration >= day { return .day }
    if let hour = Calendar.Component.hour.standardTimeInterval(), duration >= hour { return .hour }
    if let minute = Calendar.Component.minute.standardTimeInterval(), duration >= minute { return .minute }
    return .second
  }

  private func shortSymbol(for unit: Calendar.Component) -> String {
    switch unit {
      case .second: return "s"
      case .minute: return "min"
      case .hour:   return "hr"
      case .day:    return "d"  // "day" ??
      case .weekOfMonth, .weekOfYear: return "wk"
      case .month:  return "mo"
      case .year:   return "yr"
      default:
        return String(describing: unit)
    }
  }

  private static func oneFractionDigit(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 1
    formatter.maximumFractionDigits = 1
    formatter.minimumIntegerDigits = 1
    return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.1f", value)
  }
}

// MARK: - Calendar.Component helpers

public extension Calendar.Component {
  /// Average time interval for the given component, expressed in seconds.
  /// Values are approximate and suitable for relative formatting.
  func standardTimeInterval() -> TimeInterval? {
    switch self {
      case .second:     return 1
      case .minute:     return 60
      case .hour:       return 60 * 60
      case .day:        return 60 * 60 * 24
      case .weekOfYear: return 60 * 60 * 24 * 7
      case .month:      return 60 * 60 * 24 * 30.436875 // average month length in days
      case .year:       return 60 * 60 * 24 * 365.2425  // average year length in days
      default:          return nil
    }
  }
}

class DateUtils {
  public let dateFormatter: DateFormatter = {
    let myDateFormatter = DateFormatter()
    myDateFormatter.dateStyle = .short
    myDateFormatter.timeStyle = .short
    myDateFormatter.doesRelativeDateFormatting = true

    return myDateFormatter
  }()
}

extension Date {
  public func asDateTimeString() -> String {
    let formatter = DateUtils().dateFormatter
    let dateString = formatter.string(from: self)
    return dateString
  }
}
