//
//  ItemCellView.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/6/25.
//

import SwiftUI
import SwiftData
import Combine

struct ItemCellView: View {
  // IMPORTANT: Do not store the model as @State here.
  // Treat it as an input so external changes and parent ticks invalidate the view.
  var item: Item

  // Injected shared "now" from parent to avoid per-cell timers
  var nowTick: Date

  // Display mode injected from Settings so cells update reactively
  var displayMode: DisplayTimesUsing = .tenths

  // Delegate long-press to the parent so it can animate mutations that affect list ordering.
  var onLongPress: ((Item) -> Void)? = nil

  var body: some View {
    // Compute due dynamically using the shared "now"
    let due = item.isDue(now: nowTick)
    let displayColor = due ? ThemeManager.current.highlightColor : Color.primary

    // Choose the text formatter based on settings
    let elapsedText: String = {
      switch displayMode {
      case .tenths:
        return item.decimalTimeSinceText(date: nowTick)
      case .subUnits:
        return item.timeSinceText(date: nowTick)
      }
    }()

    NavigationLink {
      //ItemEditView(item: item)
      Text("ItemCellView")
    } label: {
      VStack(alignment: .leading) {
        HStack {
          Text(item.name)
            .lineLimit(2)
          Spacer()
          Text(elapsedText)
            .fontDesign(.rounded)
            .foregroundStyle(.secondary)
        }
        HStack {
          // use a method on item that returns the latest Event
          Text(item.latestEvent?.timestamp.asDateTimeString() ?? "")
          Spacer()
          Text(item.latestEvent?.value?.formatted() ?? "")
        }
        .font(.subheadline)
        .lineLimit(1)
      }
      .font(.title3)
      .fontWeight(.heavy)
      .foregroundStyle(displayColor)
      .contentShape(Rectangle())
      .onLongPressGesture {
        // Notify parent; parent performs the mutation inside withAnimation.
        onLongPress?(item)
      }
    }
  }
}

#Preview {
  // Build a concrete item (non-optional) for preview
  let previewItem: Item = {
    let it = Item(
      name: "Sample Item",
      itemDescription: "A sample description",
      config: ItemConfig(
        configName: "Sample Config",
        reminding: true,
        remindAt: .now,
        remindInterval: 1,
        timeUnits: .minute
      )
    )
    it.createEvent(timestamp: .now.addingTimeInterval(-3600), value: 3.2, notes: "Earlier")
    it.createEvent(timestamp: .now, value: 7.5, notes: "Latest")
    return it
  }()

  // A simple ticking clock for preview only (1s cadence)
  struct TickingPreview: View {
    let item: Item
    @State private var now: Date = .now
    @State private var mode: DisplayTimesUsing = .tenths

    var body: some View {
      VStack {
        Picker("Mode", selection: $mode) {
          Text("Tenths").tag(DisplayTimesUsing.tenths)
          Text("Sub-Units").tag(DisplayTimesUsing.subUnits)
        }
        .pickerStyle(.segmented)

        ItemCellView(item: item, nowTick: now, displayMode: mode, onLongPress: { itm in
          // Simulate parent mutation with animation in preview
          withAnimation {
            _ = itm.createEvent(timestamp: .now)
          }
        })
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { tick in
          now = tick
        }
        .padding()
      }
      .padding()
    }
  }

  return TickingPreview(item: previewItem)
    .modelContainer(for: [Item.self, Event.self, ItemConfig.self], inMemory: true)
}

