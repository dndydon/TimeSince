import SwiftData

// Placeholder for future schema evolution. Define model versions and mappings here.
// When you introduce breaking model changes, create new model versions and a migration plan.

enum AppSchemaVersions: Int, SchemaVersion {
    case v1 = 1
}

struct AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [V1.self] }
    static var stages: [MigrationStage] { [] } // Add stages when migrating
}

// Define your initial versioned schema
enum V1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1)
    static var models: [any PersistentModel.Type] {
        [Item.self, Event.self, RemindConfig.self, Settings.self]
    }
}
