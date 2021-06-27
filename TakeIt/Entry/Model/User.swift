//
//  User.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/15.
//

import SwiftUI

struct User: Codable {
    var id: UUID = .init()
    var nickname: String = ""
    var phoneNumber: String = ""
//    var password: String = ""
}
