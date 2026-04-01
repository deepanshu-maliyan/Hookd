//
//  Item.swift
//  Hookd
//
//  Created by Deepanshu Maliyaan on 01/04/26.
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
