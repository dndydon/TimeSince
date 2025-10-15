# SchemaV1

This document pins the initial schema. 
The Mermaid diagram and PNG are artifacts derived from the SwiftData model code.

- Mermaid ER diagram (embedded below)
- PNG snapshot: see `Models/TimeSinceERDiagram_SchemaV1` (ensure it is exported from this diagram)

```mermaid
---
title: TimeSince App — SwiftData ER Diagram (SchemaV1)
---
erDiagram
    %% Legend:
    %% - || = exactly one, o| = zero or one, o{ = zero or many
    %% - Relationship labels include cardinalities, delete rules, and inverses

    %% Pseudo-entity representing app-level storage and configuration
    App {
        String storage "SwiftData ModelContainer; AppStorage used for lightweight prefs"
    }

    %% Entities
    Item {
        UUID id PK
        String name UK "unique"
        String itemDescription
        Date createdAt
        Date lastModified
    }

    Event {
        UUID id PK
        Date timestamp
        Double value "optional"
        String notes "optional"
        UUID item_id FK "references Item.id; parent cleared during deletion"
    }

    RemindConfig {
        UUID id PK
        String configName
        Bool reminding
        Date remindAt
        Int remindInterval
        enum timeUnits "minute|hour|day|week|month|year"
    }

    Settings {
        UUID id PK
        enum displayTimesUsing "tenths|subUnits"
    }

    %% Relationships with explicit cardinalities
    App ||--o{ Item : "1..* stored in SwiftData"
    App ||--o| Settings : "0..1 active settings (SwiftData); some prefs via AppStorage"

    Item ||--o{ Event : "1..* history (inverse: Event.item, cascade)"
    Item ||--o| RemindConfig : "0..1 config"

    %% Additional Notes (as comments)
    %% - Item.name is unique (@Attribute(.unique))
    %% - Item.history inverse is Event.item; deleteRule: .cascade
    %% - Event.item is optional to allow SwiftData to clear the parent during deletion
    %% - RemindConfig.timeUnits uses Units enum: minute|hour|day|week|month|year
    %% - Settings.displayTimesUsing uses DisplayTimesUsing enum: tenths|subUnits
    %% - App is a pseudo-entity to document storage: Items/Settings in SwiftData; some lightweight prefs via AppStorage
```
