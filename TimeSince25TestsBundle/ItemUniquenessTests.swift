import Testing
import SwiftData
@testable import TimeSince25

@Suite("Item name uniqueness")
struct ItemUniquenessTests {

  @MainActor
  private func makeContainer() throws -> ModelContainer {
    let schema = Schema([Item.self, Event.self, RemindConfig.self, Settings.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    return container
  }

  @MainActor
  @Test("Duplicate names are rejected by validator")
  func testDuplicateRejected() async throws {
    let container = try makeContainer()
    let ctx = container.mainContext

    let a = Item(name: "Alpha", itemDescription: "A")
    ctx.insert(a)
    try ctx.save()

    // New item with same name should be flagged as duplicate
    #expect(throws: ItemError.duplicateName) {
      try Item.validateUniqueName(context: ctx, name: "Alpha")
    }
  }

  @MainActor
  @Test("Trimming is applied before checking uniqueness")
  func testTrimming() async throws {
    let container = try makeContainer()
    let ctx = container.mainContext

    let a = Item(name: "Bravo", itemDescription: "B")
    ctx.insert(a)
    try ctx.save()

    // Leading/trailing spaces should still be considered duplicate
    #expect(throws: ItemError.duplicateName) {
      try Item.validateUniqueName(context: ctx, name: "  Bravo  ")
    }
  }

  @MainActor
  @Test("Excluding current item allows rename to same value")
  func testExcludeSelf() async throws {
    let container = try makeContainer()
    let ctx = container.mainContext

    let a = Item(name: "Charlie", itemDescription: "C")
    ctx.insert(a)
    try ctx.save()

    // Should not throw when excluding the same item id
    try Item.validateUniqueName(context: ctx, name: "Charlie", excluding: a.id)
  }

  @MainActor
  @Test("Exists helper returns expected values")
  func testExistsHelper() async throws {
    let container = try makeContainer()
    let ctx = container.mainContext

    let a = Item(name: "Delta", itemDescription: "D")
    ctx.insert(a)
    try ctx.save()

    let e1 = try Item.exists(context: ctx, name: "Delta")
    let e2 = try Item.exists(context: ctx, name: "Echo")
    let e3 = try Item.exists(context: ctx, name: "Delta", excluding: a.id)

    #expect(e1 == true)
    #expect(e2 == false)
    #expect(e3 == false)
  }
}
