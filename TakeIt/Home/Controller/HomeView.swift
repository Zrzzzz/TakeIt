//
//  HomeView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/5/27.
//

import SwiftUI


struct HomeView: View {
    @EnvironmentObject var billConfig: BillConfig
    @EnvironmentObject var userConfig: UserConfig
    
    @Binding var tabSelection: EntryView.EntryType
    
    @State private var showAccountView: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: { showAccountView = true }, label: {
                        Text(String(format: "Banlance %.1f", billConfig.balance))
                            .bold()
                            .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                            .font(.title2)
                        Image("user")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    })
                    .padding([.vertical, .trailing], 5)
                    .padding(.leading, 20)
                    .background(Color(#colorLiteral(red: 0.9764705882, green: 0.7843137255, blue: 0.05490196078, alpha: 1)))
                    .cornerRadius(10)
                }
                
                Text("Shot")
                    .modifier(TitleModifier())
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 30) {
                        ShotView(bills: $billConfig.bills, showToday: true)
                        ShotView(bills: $billConfig.bills, showToday: false)
                    }
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            tabSelection = .statistic
                        }
                    }
                }
                
                Text("OverView")
                    .modifier(TitleModifier())
                    .padding(.bottom, 20)
                
                OverviewSectionView(bills: $billConfig.bills)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            
            ZStack {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showAccountView = false
                    }
                AccountView(showAccountView: $showAccountView)
                    .environmentObject(userConfig)
                    .environmentObject(billConfig)
            }
            .opacity(showAccountView ? 1 : 0)
            .animation(.easeInOut)
                
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(tabSelection: .constant(.home))
            .environmentObject(BillConfig())
            .environmentObject(UserConfig())
    }
}

fileprivate struct ShotView: View {
    @Binding var bills: [Bill]
    let showToday: Bool // true means today else yesterday
    
    private var dayBills: [Bill] {
        bills.filter { showToday ?
            Calendar.current.isDateInToday(Date(timeIntervalSince1970: TimeInterval($0.time))) :
            Calendar.current.isDateInYesterday(Date(timeIntervalSince1970: TimeInterval($0.time))) }
    }
    private var dayConsume: Double {
        dayBills.reduce(0, { $0 + $1.value })
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Text(showToday ? "Today" : "Yesterday")
                    .textCase(.uppercase)
                Spacer()
                Text(String(format: "¥ %.1f", dayConsume))
            }
            .foregroundColor(.white)
            .font(.system(size: 25))
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                if dayBills.isEmpty {
                    Text("No Bills Yet")
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .frame(maxHeight: .infinity)
                } else {
                    ForEach(dayBills.prefix(3)) { bill -> AnyView in
                        let isin = bill.category.type == .in
                        return AnyView(
                            HStack {
                                Image(bill.category.icon)
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                
                                Text(bill.category.name)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                Group {
                                    Text(isin ? "+" : "-")
                                    Text(String(format: "%.1f", bill.value))
                                }
                                .foregroundColor(isin ? .green : .red)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                        )
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(width: screen.width * 0.75, height: 200, alignment: .top)
        .background(Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)))
        .cornerRadius(10)
        .clipped()
        .shadow(color: Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)), radius: 5, x: 2.0, y: 2.0)
    }
}

fileprivate struct TitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.black)
            .padding(.horizontal)
    }
}

fileprivate struct OverviewSectionView: View {
    @Binding var bills: [Bill]
    @State private var overviewIdx: OverviewType = .last7
    private enum OverviewType: String, CaseIterable, Equatable {
        case last7 = "Last 7 Days"
        case thisMon = "This Month"
    }
    private var chartData: [Double] {
        var data: [Double] = []
        if overviewIdx == .last7 {
            let currentDay = Date()
            for i in stride(from: 6, to: -1, by: -1) {
                data.append(
                    bills
                        .filter { currentDay.addingTimeInterval(TimeInterval(-86400 * i)).isInSameDay(as: Date(timeIntervalSince1970: TimeInterval($0.time))) }
                        .map { $0.category.type == .in ? $0.value : -$0.value }
                        .reduce(0, +)
                )
            }
        } else {
            let today = Date()
            var day = Date()
            while day.isInSameMonth(as: today) {
                data.append(
                    bills
                        .filter { day.isInSameDay(as: Date(timeIntervalSince1970: TimeInterval($0.time))) }
                        .map { $0.category.type == .in ? $0.value : -$0.value }
                        .reduce(0, +)
                )
                day.addTimeInterval(-86400)
            }
            data.reverse()
        }
        
        return data
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(OverviewType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                        .bold()
                        .foregroundColor(type == overviewIdx ? Color.white : Color
                                            .black)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .background(type == overviewIdx ? Color(#colorLiteral(red: 0.2039215686, green: 0.3490196078, blue: 0.5843137255, alpha: 1)) : Color.white)
                        .onTapGesture {
                            withAnimation {
                                overviewIdx = type
                            }
                        }
                }
            }
            .background(Color(#colorLiteral(red: 0.01176470588, green: 0.8078431373, blue: 0.6431372549, alpha: 1)))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(#colorLiteral(red: 0.2039215686, green: 0.3490196078, blue: 0.5843137255, alpha: 1)), lineWidth: 1.0)
            )
            .cornerRadius(5)
            
            let curveViewData = Binding<[Double]>(get: {self.chartData}, set: {_ in})
            
            
            BillCurveView(data: curveViewData)
        }
        .padding()
        .background(Color(#colorLiteral(red: 0.01176470588, green: 0.8078431373, blue: 0.6431372549, alpha: 1)))
        .frame(maxWidth: screen.width * 0.85, maxHeight: 250)
        .cornerRadius(10)
        .shadow(color: Color(#colorLiteral(red: 0.01176470588, green: 0.8078431373, blue: 0.6431372549, alpha: 1)), radius: 5, x: 2, y: 2)
    }
}
