//
//  BillConfig.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/15.
//

import SwiftUI

class BillConfig: ObservableObject {
    @Published var curLedger: Int? = nil {
        didSet {
            guard userPn != "" && curLedger != nil else { return }
            bills = DataStorage.retreive("\(userPn)_\(ledgers[curLedger!].name)_data", from: .caches, as: [Bill].self) ?? []
            loadDayBills(daycnt: 7, reset: true)
        }
    }
    @Published var ledgers: [Ledger] = []
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
        categorys = DataStorage.retreive("\(userPhoneNumber)_category", from: .caches, as: [Category].self) ?? [Category(icon: "shopping", name: "shopping", type: .out, original: true),
                                                                                                                Category(icon: "game", name: "game", type: .out, original: true),
                                                                                                                Category(icon: "payoff", name: "payoff", type: .in, original: true),
                                                                                                                Category(icon: "standard", name: "standard", type: .out, original: true),
                                                                                                                Category(icon: "wage", name: "wage", type: .in, original: true),
                                                                                                                Category(icon: "redbag", name: "redbag", type: .in, original: true)]
        ledgers = (DataStorage.retreive("\(userPn)_ledgers", from: .caches, as: [Ledger].self) ?? [])
        if !ledgers.isEmpty {
            curLedger = 0
        }
    }
    
    func save() {
        DataStorage.store(ledgers, in: .caches, as: "\(userPn)_ledgers")
        DataStorage.store(categorys, in: .caches, as: "\(userPn)_category")
        guard curLedger != nil else { return }
        DataStorage.store(bills, in: .caches, as: "\(userPn)_\(ledgers[curLedger!].name)_data")
    }
    
    func loadDayBills(daycnt: Int, reset: Bool = false) {
        if reset {
            dayBills = []
            currentDate = Date()
        }
        
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
        curLedger = nil
        ledgers = []
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

