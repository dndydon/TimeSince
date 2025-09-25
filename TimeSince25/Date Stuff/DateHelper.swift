//
//  DateHelper.swift
//  clock4
//
//  Created by Don Sleeter on 1/8/18.
//  Copyright © 2018 Don Sleeter. All rights reserved.
//

import Foundation

func date(year: Int, month: Int, day: Int = 1) -> Date {
  Calendar.autoupdatingCurrent.date(
    from: DateComponents(year: year, month: month, day: day, hour: 12 ,minute: 0 ,second: 0)) ?? Date()
}

extension Calendar.Component {

  func standardTimeInterval() -> TimeInterval? {
    switch self {
      case .second: return Calendar.Component.timeIntervalForSecond
      case .minute: return Calendar.Component.timeIntervalForMinute
      case .hour: return Calendar.Component.timeIntervalForHour
      case .day: return Calendar.Component.timeIntervalForDay
      //case .week: return Calendar.Component.timeIntervalForWeek
      case .weekOfMonth: return Calendar.Component.timeIntervalForWeek
      case .month: return Calendar.Component.timeIntervalForMonth
      case .year: return Calendar.Component.timeIntervalForYear
      case .era: return nil
      case .weekday: return Calendar.Component.timeIntervalForDay
      case .weekdayOrdinal: return Calendar.Component.timeIntervalForDay
      case .quarter: return nil
      case .weekOfYear: return Calendar.Component.timeIntervalForWeek
      case .yearForWeekOfYear: return nil
      case .nanosecond: return nil
      case .calendar: return nil
      case .timeZone: return nil
      case .isLeapMonth: return nil
      case .dayOfYear: return nil
      case .isRepeatedDay:
        return nil
      @unknown default:
        return 0
    }
  }

  /// Returns number of seconds per second
  public static let timeIntervalForSecond: TimeInterval = 1

  /// Returns number of seconds per minute
  public static let timeIntervalForMinute: TimeInterval = 60

  /// Returns number of seconds per hour
  public static let timeIntervalForHour: TimeInterval = 60 * 60

  /// Returns number of seconds per 24-hour day
  public static let timeIntervalForDay: TimeInterval = 24 * 60 * 60

  /// Returns number of seconds per standard week
  public static let timeIntervalForWeek: TimeInterval = 7 * 24 * 60 * 60

  /// Returns number of seconds per average month
  public static let timeIntervalForMonth: TimeInterval = 30.4369 * 24 * 60 * 60 // 30.436875

  /// Returns number of seconds per average year
  public static let timeIntervalForYear: TimeInterval = 365.2425 * 24 * 60 * 60 // 365.2425
}

extension Date {

  /**
   *  Convenient accessor of the date's `Calendar` components.
   *
   *  - parameter component: The calendar component to access from the date
   *
   *  - returns: The Int value of the component
   *
   */
  public func component(_ component: Calendar.Component) -> Int {
    let calendar = Calendar.autoupdatingCurrent
    return calendar.component(component, from: self)
  }

  /**
   *  Convenient accessor for a DateInterval's approx. decimal representation.
   *
   *  - parameter start:  The start date of date interval.
   *
   *  - parameter end:    The end date of date interval
   *
   *  - parameter unit:   The calendar component to measure
   *
   *  - returns: The formatted string of the Decimal value
   *              of the approx. time interval, with unit, pluralized
   *  - note:    Approximate! Not using date component for math.
   */
  public func decimalAge(start: Date, end: Date, unit: Calendar.Component) -> Decimal {
    if start > end { return .zero }
    assert(start <= end, "\nStart date \(start) must be before\n  end date \(end)")
    let dateInterval = DateInterval(start: start, end: end)      // portion to measure
    let denominator = unit.standardTimeInterval() ?? .infinity   // whole unit
    let fraction: Double = dateInterval.duration/denominator     // portion/whole
    let result = fraction.formatted(.number.precision(.fractionLength(1)))
    return Decimal(Double(result) ?? 0.0) // turn it back into a number then Decimal
  }

  /**
   *  Convenience getter for the date's `hour` component
   */
  public var hour: Int {
    return component(.hour)
  }

  /**
   *  Convenience getter for the date's `minute` component
   */
  public var minute: Int {
    return component(.minute)
  }

  /**
   *  Convenience getter for the date's `second` component
   */
  public var second: Int {
    return component(.second)
  }

}

