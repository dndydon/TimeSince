//
//  RelativeTimeFormatterEnvironment.swift
//  TimeSince25
//
//  Provides a shared DSRelativeTimeFormatter via SwiftUI Environment.
//

import SwiftUI
import DSRelativeTimeFormatter

private struct RelativeTimeFormatterKey: EnvironmentKey {
  static let defaultValue = DSRelativeTimeFormatter()
}

public extension EnvironmentValues {
  var relativeTimeFormatter: DSRelativeTimeFormatter {
    get { self[RelativeTimeFormatterKey.self] }
    set { self[RelativeTimeFormatterKey.self] = newValue }
  }
}
