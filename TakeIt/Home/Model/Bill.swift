//
//  Bill.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/5/31.
//

import SwiftUI

enum BillType: String, Codable {
    case `in` = "in"
    case out = "out"
}

protocol CategoryLike: Codable {
    var icon: String { get set }
    var name: String { get set }
    var type: BillType { get set }
    var original: Bool { get set }
}

struct Category: CategoryLike {
    
    init(icon: String = "", name: String, type: BillType, original: Bool) {
        self.icon = icon
        self.name = name
        self.type = type
        self.original = original
    }
    
    var icon: String
    var name: String
    var type: BillType
    var original: Bool
}

struct Bill: Codable, Identifiable {
    let id: UUID
    let category: Category
    let remarks: String
    let value: Double
    let time: Int
}
