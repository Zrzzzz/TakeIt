//
//  EntryView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/5/27.
//

import SwiftUI

struct EntryView: View {
//    @AppStorage("userToken", store: Storage.defaults) private var userToken = ""
    enum EntryType {
        case statistic, home
    }
    @State private var userToken = ""
    @State private var selection: EntryType = .home
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                Text("statistic")
                    .tag(EntryType.statistic)
                HomeView(tabSelection: $selection)
                    .tag(EntryType.home)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            LoginView(userToken: $userToken)
//                .opacity(userToken == "" ? 1 : 0)
//                .offset(x: 0, y: userToken == "" ? 0 : screen.height)
//                .animation(
//                    Animation.easeInOut(duration: 1).delay(0.2)
//                )
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView()
    }
}
