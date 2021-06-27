//
//  StatisticView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/1.
//

import SwiftUI

typealias DayBill = (String, [Bill])

struct StatisticView: View {
    @EnvironmentObject var billConfig : BillConfig
    private var balance: Double {
        guard billConfig.curLedger != nil && billConfig.curLedger! >= 0 && billConfig.curLedger! < billConfig.ledgers.count else { return 0.0}
        return billConfig.ledgers[billConfig.curLedger!].value
    }
    
    @State private var firstLoad = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(String(format: "Balance: %.1f", balance))
                        .bold()
                        .font(.title)
                    Spacer()
                    Button(action: {
                        withAnimation { billConfig.isAddingBill = true }
                    }, label: {
                        HStack {
                            Text("Add One")
                            Image(systemName: "dollarsign.square.fill")
                                .renderingMode(.template)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                        .cornerRadius(15)
                        .clipped()
                        .shadow(color: Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)), radius: 5, x: 2, y: 2)
                    })
                }
                
                DayBillListView()
                    .onAppear {
                        guard !firstLoad else { return }
                        firstLoad = true
//                        billConfig.loadDayBills(daycnt: 3)
                    }
                    .environmentObject(billConfig)
            }
            .padding()
            
            if billConfig.isAddingBill || billConfig.isEditing {
                BlurView()
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeIn)
                    .onTapGesture {
                        withAnimation {
                            billConfig.isAddingBill = false
                            billConfig.isEditing = false
                        }
                    }
                AddBillView()
                    .environmentObject(billConfig)
                    .animation(.easeIn)
            }
            
        }
    }
}

fileprivate struct BillCellView: View {
    @Binding var bill: Bill
    
    var body: some View {
        if bill.category.type == .out {
            HStack {
                Image(systemName: "minus")
                VStack(alignment: .leading) {
                    HStack {
                        Image(bill.category.icon)
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(bill.category.name)
                        Text(String(format: "%.1f", bill.value))
                    }
                    Text(bill.remarks)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: screen.width * 0.8, alignment: .leading)
            .background(Color(#colorLiteral(red: 0.6980392157, green: 1, blue: 0.662745098, alpha: 1)))
            .cornerRadius(15)
        } else {
            HStack {
                VStack(alignment: .trailing) {
                    HStack {
                        Image(bill.category.icon)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                        Text(bill.category.name)
                        Text(String(format: "%.1f", bill.value))
                    }
                    Text(bill.remarks)
                        .font(.caption)
                        .foregroundColor(.white)
                }
                Image(systemName: "plus")
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: screen.width * 0.8, alignment: .trailing)
            .background(Color(#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)))
            .cornerRadius(15)
        }
    }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
            .environmentObject(BillConfig())
    }
}

struct BillCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BillCellView(bill: .constant(Bill(id: UUID(), category: Category(icon: "shopping", name: "shopping", type: .in, original: true), remarks: "哈哈哈", timeString: "2021-06-01", value: 2333.3, time: 1617436628)))
            BillCellView(bill: .constant(Bill(id: UUID(), category: Category(icon: "shopping", name: "shopping", type: .out, original: true), remarks: "哈哈哈", timeString: "2021-06-01", value: 2333.3, time: 1617436628)))
        }
    }
}

fileprivate struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            HStack {
                content
                Spacer()
            }
            Spacer()
        }
        .background(Color.white)
        .listRowInsets(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0))
    }
}

struct DayBillListView: View {
    @EnvironmentObject var billConfig: BillConfig
    @State private var currentDate = Date()
    @State private var lStr: String = "loading..."
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(billConfig.dayBills, id: \.0) { dayBill -> AnyView in
                    let dayIn = dayBill.1.filter { $0.category.type == .in }.map{ $0.value }.reduce(0, +)
                    let dayOut = dayBill.1.filter { $0.category.type == .out }.map{ $0.value }.reduce(0, +)
                    let dayTotal = dayIn - dayOut
                    
                    return AnyView(Section(header:
                                            HStack(alignment: .top) {
                                                Text(dayBill.0)
                                                    .bold()
                                                    .font(.title3)
                                                Spacer()
                                                Text(String(format: "In: %.1f Out: %.1f\nTotal: %.1f", dayIn, dayOut, dayTotal))
                                            }
                                            .modifier(SectionHeaderModifier())
                    ) {
                        VStack {
                            ForEach(dayBill.1, id: \.id) { bill in
                                Menu {
                                    Button(action: {
                                        withAnimation {
                                            editBill(bill: bill)
                                        }
                                    }, label: {
                                        Text("Edit")
                                    })
                                    Button(action: {
                                        withAnimation {
                                            deleteBill(bill: bill)
                                        }
                                    }, label: {
                                        Text("Delete")
                                            .foregroundColor(.red)
                                    })
                                } label: {
                                    BillCellView(bill: .constant(bill))
                                        .frame(maxWidth: .infinity, alignment: bill.category.type == .in ? .trailing : .leading)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    })
                }
                
                Text(lStr)
                    .onAppear {
                        billConfig.loadDayBills(daycnt: 5)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            lStr = "No more"
                        }
                    }
                    .onDisappear {
                        lStr = "loading..."
                    }
            }
        }
    }
    
    private func editBill(bill: Bill) {
        billConfig.isEditing = true
        billConfig.dayBillToEdit = bill
    }
    
    private func deleteBill(bill: Bill) {
        guard billConfig.curLedger != nil && billConfig.curLedger! >= 0 && billConfig.curLedger! < billConfig.ledgers.count else { return }
        billConfig.ledgers[billConfig.curLedger!].value -= (bill.category.type == .in ? bill.value : -bill.value)
        billConfig.bills.removeAll(where: { $0 == bill })
        // 更新dayBills 没必要重复加载dayBills
        for i in billConfig.dayBills.indices {
            billConfig.dayBills[i].1.removeAll { $0 == bill }
            if billConfig.dayBills[i].1.isEmpty {
                billConfig.dayBills.remove(at: i)
                break
            }
        }
        billConfig.save()
    }
}
