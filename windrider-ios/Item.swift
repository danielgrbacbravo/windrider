//
//  Item.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 29/02/2024.
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
