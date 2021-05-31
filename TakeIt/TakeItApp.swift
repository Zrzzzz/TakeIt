//
//  TakeItApp.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/5/27.
//

import SwiftUI

@main
struct TakeItApp: App {
    @AppStorage("userToken", store: Storage.defaults) private var userToken: String = ""
    
    var body: some Scene {
        WindowGroup {
            EntryView()
        }
    }
}

extension View {
    var screen: CGRect { UIScreen.main.bounds }
}
