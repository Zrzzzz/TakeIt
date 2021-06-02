//
//  AddBillView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/2.
//

import SwiftUI

struct AddBillView: View {
    @State private var billType: BillType = .out
    @State private var newBill: Bill = Bill(id: UUID(), category: Category(icon: "", name: "", type: .in, original: true), remarks: "", timeString: "", value: 0, time: Int(Date().timeIntervalSince1970))
    @State private var billValue: String = "0.0"
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    private var categorys: [Category] = [
        Category(icon: "shopping", name: "shopping", type: .out, original: true),
        Category(icon: "game", name: "game", type: .out, original: true),
        Category(icon: "payoff", name: "payoff", type: .in, original: true),
        Category(icon: "standard", name: "standard", type: .out, original: true),
        Category(icon: "wage", name: "wage", type: .in, original: true),
        Category(icon: "redbag", name: "redbag", type: .in, original: true)
    ]
    
    var body: some View {
        let billDate = Binding<Date>(get: { Date(timeIntervalSince1970: TimeInterval(newBill.time)) }) { (date) in
            newBill.time = Int(date.timeIntervalSince1970)
        }
        
        VStack {
            HStack {
                Text("Add Bill")
                    .bold()
                    .font(.title)
                    .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                
                Spacer()
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            
            VStack {
                
                VStack {
                    TextField("value", text: $billValue, onEditingChanged: { _ in
                        billValue = String(newBill.value)
                    }, onCommit: {
                        guard billValue.reduce(0, { $0 + ($1 == "." ? 1 : 0) }) < 2 else { return }
                        newBill.value = Double(billValue) ?? 0
                    })
                    .keyboardType(.decimalPad)
                    
                    Separator(width: screen.width * 0.7)
                    
                    TextField("remarks", text: $newBill.remarks)
                    
                    Separator(width: screen.width * 0.7)
                    
                    DatePicker("time", selection: billDate)
                }
                
                
                HStack {
                    Image(systemName: "dollarsign.square.fill")
                    Picker(selection: $billType, label:
                            Text(billType.rawValue)
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
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    let svWidth = screen.width / 1.5
                    let svHeight = svWidth * 1.4
                    HStack {
                        Spacer(minLength: (screen.width - svWidth) / 2)
                        
                        ForEach(categorys.filter { $0.type == billType }, id: \.self) { category in
                            GeometryReader { g in
                                VStack {
                                    Text(category.name)
                                    Image(category.icon)
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                                    .scaleEffect(1 - (abs((g.frame(in: .global).midX - screen.width / 2))) / (screen.width * 3))
                                    .rotation3DEffect(Angle(degrees:Double(g.frame(in: .global).midX - screen.width / 2) / -20), axis: (x: 0, y: 1, z: 0))

                            }
                            .frame(width: svWidth, height: svHeight)
                        }
                        
                        
                        Spacer(minLength: (screen.width - svWidth) / 2)
                    }
                }
            }
            .padding()
            .frame(width: screen.width * 0.85)
            .background(Color.white.opacity(0.6))
            .cornerRadius(15)
            
            
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)).edgesIgnoringSafeArea(.all))
    }
}

public struct Separator: View {
    let width: CGFloat
    
    public var body: some View {
        Color.gray.frame(width: width, height: 1)
    }
}

struct AddBillView_Previews: PreviewProvider {
    static var previews: some View {
        AddBillView()
    }
}
