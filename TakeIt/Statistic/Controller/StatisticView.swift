//
//  StatisticView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/1.
//

import SwiftUI

struct StatisticView: View {
    @State private var bills: [Bill] = []
    
    private var balance: Double {
        return bills.map{ $0.category.type == .in ? $0.value : -$0.value }.reduce(0, +)
    }
    
    private typealias DayBill = (String, [Bill])
    @State private var currentDate = Date()
    @State private var dayBills: [DayBill] = []
    
    var body: some View {
        VStack {
            HStack {
                Text(String(format: "Balance: %.1f", balance))
                    .bold()
                    .font(.title)
                Spacer()
                Button(action: {}, label: {
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
            
            List {
                ForEach(dayBills, id: \.0) { dayBill -> AnyView in
                    let dayIn = dayBill.1.filter { $0.category.type == .in }.map{ $0.value }.reduce(0, +)
                    let dayOut = dayBill.1.filter { $0.category.type == .out }.map{ $0.value }.reduce(0, +)
                    let dayTotal = dayIn + dayOut
                    
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
                                BillCellView(bill: bill)
                                    .frame(maxWidth: .infinity, alignment: bill.category.type == .in ? .trailing : .leading)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    })
                }
            }
        }
        .onAppear(perform: {
            loadStoredBills()
            loadData(daycnt: 7)
        })
    }
    
    private func loadStoredBills() {
        if let filepath = Bundle.main.path(forResource: "testdata", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let decodedData = try JSONDecoder().decode([Bill].self, from: contents.data(using: .utf8)!)
                self.bills = decodedData
            } catch {
                log(error)
            }
        } else {
            log("Can't find data file")
        }
    }
    
    private func loadData(daycnt: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        
        for _ in 0..<daycnt {
            let daystr = formatter.string(from: currentDate)
            dayBills.append((daystr, bills.filter { Date(timeIntervalSince1970: TimeInterval($0.time)).isInSameDay(as: currentDate) }))
            print(dayBills)
            currentDate.addTimeInterval(-86400)
        }
    }
}

fileprivate struct BillCellView: View {
    @State var bill: Bill
    
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
    }
}

struct BillCellView_Previews: PreviewProvider {
    static var previews: some View {
        BillCellView(bill: Bill(id: UUID(), category: Category(icon: "shopping", name: "shopping", type: .in, original: true), remarks: "哈哈哈", timeString: "2021-06-01", value: 2333.3, time: 1617436628))
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
