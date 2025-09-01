//
//  Item.swift
//  TimeSince25
//
//  Created by Don Sleeter on 9/1/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
