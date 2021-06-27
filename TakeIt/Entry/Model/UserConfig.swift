//
//  UserConfig.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/26.
//

import SwiftUI

class UserConfig: ObservableObject {
    @Published var user = User()
    
    func load(pn: String) {
        let users = DataStorage.retreive("user_data", from: .caches, as: [User].self) ?? []
        if let idx = users.firstIndex(where: { $0.phoneNumber == pn }) {
            user = users[idx]
        }
    }
    
    func save() {
        var users = DataStorage.retreive("user_data", from: .caches, as: [User].self) ?? []
        if users.contains(where: { $0.id == user.id }) {
            users[users.firstIndex(where: { $0.id == user.id })!] = user
        } else {
            users.append(user)
        }
        DataStorage.store(users, in: .caches, as: "user_data")
    }
    
    func clear() {
        user = User()
    }
}
