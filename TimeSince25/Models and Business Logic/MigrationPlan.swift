import SwiftData

// Placeholder for future schema evolution. Define model versions and mappings here.
// When you introduce breaking model changes, create new model versions and a migration plan.

// MARK: - Versioned Schemas for Migration

// Define your initial versioned schema
enum schemaV1: VersionedSchema {

  // Use Schema.Version to identify the version; this is a constant value.
  static let versionIdentifier = Schema.Version(1, 0, 0)

  static var models: [any PersistentModel.Type] {
    [Item.self, Event.self, RemindConfig.self, Settings.self]
  }
}

// Define your second versioned schema
// enum schemaV2: VersionedSchema {
//   static let versionIdentifier = Schema.Version(2, 0, 0)
//
//   static var models: [any PersistentModel.Type] {
//     // Updated models for V2
//     [Item.self, Event.self, RemindConfig.self, Settings.self]
//   }
// }


// MARK: - App Migration Plan

// Define the migration plan using SwiftData's SchemaMigrationPlan
struct AppMigrationPlan: SchemaMigrationPlan {
  // List all versioned schemas in order
  static var schemas: [any VersionedSchema.Type] { [schemaV1.self] }

  // Add migration stages when you introduce new versions
  static var stages: [MigrationStage] { [] }
}

/// When there IS a V2...
// struct AppMigrationPlan: SchemaMigrationPlan {
//   static var schemas: [any VersionedSchema.Type] { [schemaV1.self, schemaV2.self] }
//
//   static var stages: [MigrationStage] {
//     [
//       .init(from: schemaV1.self, to: schemaV2.self, willMigrate: { context in
//         // Optional: pre-migration tasks
//       }, didMigrate: { context in
//         // Optional: post-migration fixups
//       })
//     ]
//   }
// }
