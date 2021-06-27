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
    @State private var selection: EntryType = .home
    @ObservedObject private var billConfig = BillConfig()
    @ObservedObject private var userConfig = UserConfig()
    @AppStorage("login") var login: Bool = false
    @AppStorage("pn") var pn: String = ""
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                StatisticView()
                    .tag(EntryType.statistic)
                    .environmentObject(billConfig)
                HomeView(tabSelection: $selection)
                    .tag(EntryType.home)
                    .environmentObject(billConfig)
                    .environmentObject(userConfig)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            LoginView()
                .opacity(!login ? 1 : 0)
                .offset(x: 0, y: !login ? 0 : screen.height)
                .animation(
                    Animation.easeInOut(duration: 1).delay(0.2)
                )
                .environmentObject(userConfig)
                .environmentObject(billConfig)
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            UIScrollView.appearance().alwaysBounceVertical = false
            loadCache()
//            loadStoredBillsToCache()
        }
    }
    
    
    private func loadStoredBillsToCache() {
        if let filepath = Bundle.main.path(forResource: "testdata", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let decodedData = try JSONDecoder().decode([Bill].self, from: contents.data(using: .utf8)!)
                let bills = decodedData
                DataStorage.store(bills, in: .caches, as: "\(userConfig.user.phoneNumber)_\(billConfig.ledgers[billConfig.curLedger!].name)_data")
                billConfig.ledgers[billConfig.curLedger!].value = bills.reduce(0, { $1.category.type == .in ? $0 + $1.value : $0 - $1.value} )
            } catch {
                log(error)
            }
        } else {
            log("Can't find data file")
        }
    }
    
    private func loadCache() {
        if login {
            billConfig.loadData(userPhoneNumber: pn)
            userConfig.load(pn: pn)
        }
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView()
    }
}
