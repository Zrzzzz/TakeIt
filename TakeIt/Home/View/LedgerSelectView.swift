//
//  LedgerSelectView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/23.
//

import SwiftUI

struct LedgerSelectView: View {
    @EnvironmentObject var billConfig: BillConfig
    @EnvironmentObject var userConfig: UserConfig
    
    @Binding var selectLedger: Bool
    
    private let cols = [GridItem(.flexible()), GridItem(.flexible()),GridItem(.flexible())]
    @State private var addLedger: Bool = false
    @State private var ledgerName: String? = ""
    
    @State private var editing: Bool = false
    
    var body: some View {
        VStack {
            SlideBar()
                .padding(.top)
            
            HStack {
                Button(action: {
                    addLedger = true
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                })
                Spacer()
                Button(action: {
                    editing.toggle()
                }, label: {
                    Text(editing ? "Cancel" : "Edit")
                })
                .animation(.default)
            }
            .padding(.horizontal)
            
            ScrollView {
                if billConfig.ledgers.isEmpty {
                    Text("Create your first ledger to continue.")
                }
                
                LazyVGrid(columns: cols, content: {
                    ForEach(billConfig.ledgers.indices, id: \.self) { i in
                        ZStack {
                            Image("ledger")
                                .resizable()
                                .scaledToFit()
                            
                            Button(action: {
                                if !editing {
                                    billConfig.curLedger = i
                                    selectLedger = false
                                    billConfig.save()
                                }
                            }, label: {
                                VStack(alignment: .leading) {
                                    Text(billConfig.ledgers[i].name)
                                    Text(String(format: "%.1f", billConfig.ledgers[i].value))
                                }
                                .foregroundColor((billConfig.curLedger ?? 0 == i) ? .red : .black)
                            })
                            
                            Button(action: {
                                deleteLedger(i)
                                editing = false
                            }, label: {
                                Circle()
                                    .foregroundColor(.red)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Color.white
                                            .frame(width: 10, height: 3)
                                    )
                            })
                            .opacity(editing ? 1 : 0)
                            .animation(.default)
                            .offset(x: 40, y: -40)
                        }
                        
                        .rotationEffect(.init(degrees: editing ? -3 : 0))
                        .animation(editing ? Animation.default.speed(4).repeatForever() : .default)
                    }
                })
            }
        }
        .textFieldAlert(isPresented: $addLedger, content: {
            TextFieldAlert(title: "Fill in ledger name", message: "ledger name", text: $ledgerName) {
                DispatchQueue.main.async {
                    self.billConfig.ledgers.append(Ledger(userPn: userConfig.user.phoneNumber, name: ledgerName ?? "", value: 0.0))
                    self.billConfig.curLedger = billConfig.ledgers.count - 1
                    if billConfig.curLedger == nil {
                        billConfig.curLedger = 0
                    }
                    billConfig.save()
                }
            }
        })
        .onAppear {
//            billConfig.ledgers = [
//                Ledger(userPn: "", name: "life", value: 3232.1),
//                Ledger(userPn: "", name: "work", value: -220.5),
//                Ledger(userPn: "", name: "life", value: 3232.0),
//                Ledger(userPn: "", name: "work", value: -220.4)
//            ]
        }
    }
    
    private func deleteLedger(_ idx: Int) {
        DataStorage.remove("\(userConfig.user.phoneNumber)_\(billConfig.ledgers[billConfig.curLedger!].name)_data", from: .caches)
        self.billConfig.ledgers.remove(at: idx)
        self.billConfig.bills.removeAll()
        self.billConfig.dayBills.removeAll()
        self.billConfig.curLedger = self.billConfig.ledgers.isEmpty ? nil : 0
        self.billConfig.save()
    }
}

struct LedgerSelectView_Previews: PreviewProvider {
    static var previews: some View {
        LedgerSelectView(selectLedger: .constant(true))
            .environmentObject(BillConfig())
            .environmentObject(UserConfig())
            
    }
}
