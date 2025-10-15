import Foundation
import SwiftData

// MARK: - Versioned Schemas for Migration

// V1 schema: the original schema that used ItemConfig
// We only need to describe the parts necessary for migration identity.
// Other models can reference the current definitions if unchanged, but for safety
// we reference only the renamed model here and let the lightweight migration handle the rest.
/*
enum AppSchemaV1: VersionedSchema {
  static var versionIdentifier: Schema.Version { .init(1, 0, 0) }

  static var models: [any PersistentModel.Type] {
    [Item.self, Event.self, ItemConfig.self, Settings.self]
  }

  // Minimal V1 definition of ItemConfig to provide the old entity identity.
  // This mirrors the stored properties used at that time.
  @Model
  final class ItemConfig: Identifiable, Hashable {
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

    static func == (lhs: ItemConfig, rhs: ItemConfig) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
  }
}

// V2 schema: the current schema that uses RemindConfig (renamed from ItemConfig)

enum AppSchemaV2: VersionedSchema {
  static var versionIdentifier: Schema.Version { .init(2, 0, 0) }

  static var models: [any PersistentModel.Type] {
    [Item.self, Event.self, RemindConfig.self, Settings.self]
  }
}

// Migration plan: lightweight rename from V1 -> V2

enum AppMigrationPlan: SchemaMigrationPlan {
  static var schemas: [any VersionedSchema.Type] { [AppSchemaV1.self, AppSchemaV2.self] }

  static var stages: [MigrationStage] {
    [
      .lightweight(fromVersion: AppSchemaV1.self, toVersion: AppSchemaV2.self)
    ]
  }
}
*/ // nothing needed here now
