//
//  BillConfig.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/15.
//

import SwiftUI

class BillConfig: ObservableObject {
    @Published var bills: [Bill] = []
    @Published var dayBills: [DayBill] = []
    @Published var categorys: [Category] = [Category(icon: "shopping", name: "shopping", type: .out, original: true),
                                            Category(icon: "game", name: "game", type: .out, original: true),
                                            Category(icon: "payoff", name: "payoff", type: .in, original: true),
                                            Category(icon: "standard", name: "standard", type: .out, original: true),
                                            Category(icon: "wage", name: "wage", type: .in, original: true),
                                            Category(icon: "redbag", name: "redbag", type: .in, original: true)]
    @Published var isAddingBill: Bool = false
    @Published var isEditing: Bool = false
    @Published var dayBillToEdit: Bill = Bill(id: UUID(), category: .init(icon: "", name: "", type: .in, original: true), remarks: "", timeString: "", value: 0, time: 0)
    
    private var userPn: String = ""
    private var currentDate = Date()
    
    var balance: Double {
        bills.map{ $0.category.type == .in ? $0.value : -$0.value }.reduce(0, +)
    }
    
    var billCount: Int { bills.count }
    
    func loadData(userPhoneNumber: String) {
        userPn = userPhoneNumber
        bills = DataStorage.retreive("\(userPhoneNumber)_data", from: .caches, as: [Bill].self) ?? []
        categorys = DataStorage.retreive("\(userPhoneNumber)_category", from: .caches, as: [Category].self) ?? [Category(icon: "shopping", name: "shopping", type: .out, original: true),
                                                                                                                Category(icon: "game", name: "game", type: .out, original: true),
                                                                                                                Category(icon: "payoff", name: "payoff", type: .in, original: true),
                                                                                                                Category(icon: "standard", name: "standard", type: .out, original: true),
                                                                                                                Category(icon: "wage", name: "wage", type: .in, original: true),
                                                                                                                Category(icon: "redbag", name: "redbag", type: .in, original: true)]
    }
    
    func saveData() {
        DataStorage.store(bills, in: .caches, as: "\(userPn)_data")
        DataStorage.store(categorys, in: .caches, as: "\(userPn)_category")
    }
    
    func loadDayBills(daycnt: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        
        for _ in 0..<daycnt {
            let daystr = formatter.string(from: currentDate)
            let _bills = bills.filter { Date(timeIntervalSince1970: TimeInterval($0.time)).isInSameDay(as: currentDate) }
            if !_bills.isEmpty {
                dayBills.append((daystr, _bills))
            }
            currentDate.addTimeInterval(-86400)
        }
    }
    
    func clear() {
        bills = []
        dayBills = []
        categorys = [Category(icon: "shopping", name: "shopping", type: .out, original: true),
                     Category(icon: "game", name: "game", type: .out, original: true),
                     Category(icon: "payoff", name: "payoff", type: .in, original: true),
                     Category(icon: "standard", name: "standard", type: .out, original: true),
                     Category(icon: "wage", name: "wage", type: .in, original: true),
                     Category(icon: "redbag", name: "redbag", type: .in, original: true)]
        isAddingBill = false
        isEditing = false
        dayBillToEdit = Bill(id: UUID(), category: .init(icon: "", name: "", type: .in, original: true), remarks: "", timeString: "", value: 0, time: 0)
    }
}
