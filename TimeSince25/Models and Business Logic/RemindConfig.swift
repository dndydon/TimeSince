//
//  RemindConfig.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/29/25.
//

import Foundation
import SwiftData


@Model
class RemindConfig: Identifiable, Hashable {
  // Stable identity separate from the user-visible name
  var id: UUID

  var configName: String
  var reminding: Bool
  var remindAt: Date
  var remindInterval: Int
  var timeUnits: Units

  init(id: UUID = UUID(), configName: String, reminding: Bool, remindAt: Date, remindInterval: Int, timeUnits: Units) {
    self.id = id
    self.configName = configName
    self.reminding = reminding
    self.remindAt = remindAt
    self.remindInterval = remindInterval
    self.timeUnits = timeUnits
  }

  // MARK: - Hashable
  static func == (lhs: RemindConfig, rhs: RemindConfig) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
