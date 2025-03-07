//
//  Item.swift
//  meteory
//
//  Created by Gilchrist Prem on 2025-03-04.
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
