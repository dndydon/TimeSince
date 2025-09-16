import Foundation

enum RemindLogic {

  // Compute the next due date from the last event date, using calendar-aware math.
  static func nextDueDate(since lastEvent: Date, using config: ItemConfig, calendar: Calendar = .current) -> Date? {
    guard config.reminding else { return nil }

    let interval = max(1, config.remindInterval)
    switch config.timeUnits {
    case .minute:
      return calendar.date(byAdding: .minute, value: interval, to: lastEvent)
    case .hour:
      return calendar.date(byAdding: .hour, value: interval, to: lastEvent)
    case .day:
      // Add days, then align time-of-day to remindAt hour/minute
      guard let added = calendar.date(byAdding: .day, value: interval, to: lastEvent) else { return nil }
      return align(added, toTimeOf: config.remindAt, calendar: calendar)
    case .week:
      guard let added = calendar.date(byAdding: .weekOfYear, value: interval, to: lastEvent) else { return nil }
      return align(added, toTimeOf: config.remindAt, calendar: calendar)
    case .month:
      guard let added = calendar.date(byAdding: .month, value: interval, to: lastEvent) else { return nil }
      return align(added, toTimeOf: config.remindAt, calendar: calendar)
    case .year:
      guard let added = calendar.date(byAdding: .year, value: interval, to: lastEvent) else { return nil }
      return align(added, toTimeOf: config.remindAt, calendar: calendar)
    }
  }

  // Determine if an item is currently due.
  static func isDue(now: Date = .now, lastEvent: Date, config: ItemConfig, calendar: Calendar = .current) -> Bool {
    guard config.reminding, let due = nextDueDate(since: lastEvent, using: config, calendar: calendar) else {
      return false
    }
    return now >= due
  }

  // A human-readable summary of the reminder settings.
  static func reminderSummary(config: ItemConfig, locale: Locale = .current) -> String {
    guard config.reminding else { return "Reminders off" }

    let n = max(1, config.remindInterval)
    let unitName = localizedUnitName(units: config.timeUnits, count: n, locale: locale)

    switch config.timeUnits {
    case .minute, .hour:
      // No time-of-day anchor for sub-day intervals
      if n == 1 {
        return "Every 1 \(unitName)"
      } else {
        return "Every \(n) \(unitName)"
      }
    case .day, .week, .month, .year:
      let timeString = timeOfDayString(config.remindAt, locale: locale)
      if n == 1 {
        return "Every 1 \(unitName) at \(timeString)"
      } else {
        return "Every \(n) \(unitName) at \(timeString)"
      }
    }
  }

  // MARK: - Helpers

  private static func align(_ date: Date, toTimeOf anchor: Date, calendar: Calendar) -> Date {
    let comps = calendar.dateComponents([.year, .month, .day], from: date)
    let time = calendar.dateComponents([.hour, .minute, .second], from: anchor)
    var merged = DateComponents()
    merged.year = comps.year
    merged.month = comps.month
    merged.day = comps.day
    merged.hour = time.hour
    merged.minute = time.minute
    merged.second = time.second
    return calendar.date(from: merged) ?? date
  }

  private static func timeOfDayString(_ date: Date, locale: Locale) -> String {
    let fmt = DateFormatter()
    fmt.locale = locale
    fmt.timeStyle = .short
    fmt.dateStyle = .none
    return fmt.string(from: date)
  }

  private static func localizedUnitName(units: Units, count: Int, locale: Locale) -> String {
    // Very light localization-ready approach; for now, English pluralization.
    switch units {
    case .minute: return count == 1 ? "minute" : "minutes"
    case .hour:   return count == 1 ? "hour"   : "hours"
    case .day:    return count == 1 ? "day"    : "days"
    case .week:   return count == 1 ? "week"   : "weeks"
    case .month:  return count == 1 ? "month"  : "months"
    case .year:   return count == 1 ? "year"   : "years"
    }
  }
}
