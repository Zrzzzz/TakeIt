//
//  AddBillView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/2.
//

import SwiftUI

struct AddBillView: View {
    @State private var newBill: Bill = Bill(id: UUID(), category: Category(icon: "wage", name: "wage", type: .in, original: true), remarks: "", timeString: "", value: 0, time: Int(Date().timeIntervalSince1970))
    @State private var billValue: String = "0.0"
    @State private var showCategoryEditor: Bool = false
    
    @EnvironmentObject var billConfig: BillConfig
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        let billDate = Binding<Date>(get: { Date(timeIntervalSince1970: TimeInterval(newBill.time)) }) { (date) in
            newBill.time = Int(date.timeIntervalSince1970)
        }
        
        VStack {
            
            VStack {
                TextField("value", text: $billValue, onEditingChanged: { _ in
                    billValue = String(format: "%.1f", newBill.value)
                }, onCommit: {
                    guard billValue.reduce(0, { $0 + ($1 == "." ? 1 : 0) }) < 2 else { return }
                    newBill.value = Double(billValue) ?? 0
                })
                .keyboardType(.decimalPad)
                
                Separator(width: .infinity)
                
                TextField("remarks", text: $newBill.remarks)
                
                Separator(width: .infinity)
                
                DatePicker("time", selection: billDate)
            }
            
            Separator(width: .infinity)
                .padding(.bottom, 5)
            
            HStack {
                Image(systemName: "dollarsign.square.fill")
                Picker(selection: $newBill.category.type, label:
                        Text(newBill.category.type.rawValue)
                        .bold()
                        .foregroundColor(.black)
                        .textCase(.uppercase)
                       
                       , content: {
                        Text(BillType.in.rawValue)
                            .textCase(.uppercase)
                            .tag(BillType.in)
                        
                        Text(BillType.out.rawValue)
                            .textCase(.uppercase)
                            .tag(BillType.out)
                       })
                    .pickerStyle(MenuPickerStyle())
                Spacer()
                
                Button(action: {
                    showCategoryEditor = true
                }, label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.black)
                })
            }
            
            Picker(selection: $newBill.category, label: Text(newBill.category.name), content: {
                ForEach(billConfig.categorys.filter{ $0.type == newBill.category.type }, id: \.self) { category in
                    HStack {
                        Text(category.name)
                        Spacer()
                        Image(category.icon)
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                    .frame(width: screen.width * 0.5)
                    .tag(category)
                }
            })
            .pickerStyle(WheelPickerStyle())
            
            Separator(width: .infinity)
            
            HStack {
                Button(action: {
                    withAnimation {
                        billConfig.isAddingBill = false
                        billConfig.isEditing = false
                    }
                }, label: {
                    Text("cancel")
                        .foregroundColor(.secondary)
                })
                .padding(.trailing, 80)
                
                Button(action: {
                    withAnimation {
                        addBill()
                        billConfig.isAddingBill = false
                        billConfig.isEditing = false
                    }
                }, label: {
                    Text(billConfig.isEditing ? "Edit" : "Add")
                })
            }
        }
        .padding()
        .frame(width: screen.width * 0.85)
        .background(Color.white.opacity(0.6))
        .cornerRadius(15)
        .sheet(isPresented: $showCategoryEditor, content: {
            CategoryEditView(showCategoryEditor: $showCategoryEditor)
                .environmentObject(billConfig)
        })
        .onAppear {
            if billConfig.isEditing {
                newBill = billConfig.dayBillToEdit
                billValue = String(format: "%.1f", billConfig.dayBillToEdit.value)
            }
        }
    }
    
    private func addBill() {
        // 编辑账单
        if billConfig.isEditing {
            let billIdx = billConfig.bills.firstIndex(where: { $0.id == newBill.id })
            guard billIdx != nil else { return }
            billConfig.bills[billIdx!] = newBill
            billConfig.ledgers[billConfig.curLedger!].value += (
                (billConfig.bills[billIdx!].category.type == .in ? billConfig.bills[billIdx!].value : -billConfig.bills[billIdx!].value) +
                    (newBill.category.type == .in ? newBill.value : -newBill.value)
            )
            for i in billConfig.dayBills.indices {
                let idx = billConfig.dayBills[i].1.firstIndex(where: { $0.id == newBill.id })
                guard idx != nil else { continue }
                billConfig.dayBills[i].1[idx!] = newBill
            }
        }
        // 添加账单
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            billConfig.bills.append(newBill)
            let dayIdx = billConfig.dayBills.firstIndex(where: { $0.0 == formatter.string(from: Date()) })
            if dayIdx != nil {
                billConfig.dayBills[dayIdx!].1.append(newBill)
            } else {
                billConfig.dayBills.insert((formatter.string(from: Date()), [newBill]), at: 0)
            }
            billConfig.ledgers[billConfig.curLedger!].value += (newBill.category.type == .in ? newBill.value : -newBill.value)
        }
        
        billConfig.save()
    }
}

public struct Separator: View {
    let width: CGFloat
    
    public var body: some View {
        if width == .infinity {
            Color.gray
                .frame(maxWidth: .infinity)
                .frame(height: 1)
        } else {
            Color.gray.frame(width: width, height: 1)
        }
    }
}

struct AddBillView_Previews: PreviewProvider {
    static var previews: some View {
        AddBillView()
            .environmentObject(BillConfig())
    }
}
