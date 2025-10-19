//
//  Settings.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/1/25.
//

import Foundation
import SwiftData


@Model
class Settings: Identifiable, Hashable {
  // Stable identity separate from the user-visible name
  var id: UUID

  var displayTimesUsing: DisplayTimesUsing
  var showDetails: Bool

  init(
    id: UUID = UUID(),
    displayTimesUsing: DisplayTimesUsing = .tenths,
    showDetails: Bool = false,
  ) {
    self.id = id
    self.displayTimesUsing = displayTimesUsing
    self.showDetails = showDetails
  }

  // MARK: - Hashable
  static func == (lhs: Settings, rhs: Settings) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

enum DisplayTimesUsing: String, Codable {
  case tenths = "tenths"
  case subUnits = "subUnits"
}

enum Units: String, Codable {
  case minute
  case hour
  case day
  case week
  case month
  case year
}
