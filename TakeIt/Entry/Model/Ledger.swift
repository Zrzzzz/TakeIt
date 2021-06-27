//
//  Ledger.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/26.
//

import SwiftUI

struct Ledger: Codable, Hashable {
    var userPn: String = ""
    var name: String = ""
    var value: Double = 0
    
    mutating func update(value: Double) {
        self.value += value
    }
}
