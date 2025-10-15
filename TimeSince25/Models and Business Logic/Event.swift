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

  // Stable identity separate from any/all stored properties
  var id: UUID

  var timestamp: Date
  var value: Double?
  var notes: String?

  // Make the parent relationship optional so SwiftData can clear it during deletion.
  var item: Item?

  // Require the owning Item at init time
  init(
    id: UUID = UUID(),
    item: Item,
    timestamp: Date = .now,
    value: Double? = nil,
    notes: String? = nil
  ) {
    self.id = id
    self.item = item
    self.timestamp = timestamp
    self.value = value
    self.notes = notes
  }

  // MARK: - Hashable
  // use custom Hashable conformance so equality and hashing are defined
  // exclusively by the id. This aligns with your use of Identifiable
  // and avoids surprises as the model evolves.

  static func == (lhs: Event, rhs: Event) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
