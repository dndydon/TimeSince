# Schema Versioning

Diagrams and snapshots are artifacts derived from model source code. The model code is the source of truth.

## Policy
- Version directories: `SchemaV1`, `SchemaV2`, ...
- Each version contains:
  - Mermaid ER diagram (inline in the version README)
  - PNG snapshot exported from the Mermaid diagram (checked in for GitHub rendering)
  - Notes about constraints and delete rules
  - Migration notes from the previous version

## How to Update
1. Update SwiftData models in `Models/`.
2. Regenerate Mermaid ER diagram from models (script/tooling TBD) and update the version README.
3. Export PNG from Mermaid and place it under `Models/` and/or `docs/Schema/<Version>/`.
4. Write migration notes and tests.

See `SchemaV1.md` for the initial schema.
