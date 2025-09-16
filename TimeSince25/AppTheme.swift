import SwiftUI

struct Theme: Equatable {
  var highlightColor: Color
}

enum ThemeManager {
  private(set) static var current: Theme = defaultTheme()

  static func defaultTheme(for locale: Locale = .current) -> Theme {
    // Placeholder for locale-aware defaults; using red is a common alert color.
    Theme(highlightColor: .red)
  }

  static func defaultTheme() -> Theme {
    defaultTheme(for: .current)
  }

  // In the future, you can add APIs to switch themes or load from persistence.
}
