//
//  Event.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/29/25.
//


import Foundation
import SwiftData


@Model
class Event: Identifiable, Hashable {
  // Stable identity separate from the user-visible name
  var id: UUID

  var timestamp: Date
  var value: Double?
  var notes: String?

  // Make the parent relationship optional so SwiftData can clear it during deletion.
  var item: Item?

  // Require the owning Item at init time
  init(id: UUID = UUID(), item: Item, timestamp: Date = .now, value: Double? = nil, notes: String? = nil) {
    self.id = id
    self.item = item
    self.timestamp = timestamp
    self.value = value
    self.notes = notes
  }

  // MARK: - Hashable
  static func == (lhs: Event, rhs: Event) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
