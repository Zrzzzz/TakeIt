//
//  AccountView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/15.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var userConfig: UserConfig
    @EnvironmentObject var billConfig: BillConfig
    @Binding var showAccountView: Bool
    
    @State private var nickname: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMsg: String = ""
    
    @State private var isEditing: Bool = false
    @AppStorage("login") var login: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("user")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                Text(userConfig.user.nickname)
                Spacer()
                Button(action: {
                    withAnimation { saveOrEdit() }
                }, label: {
                    Text(isEditing ? "save" : "Edit Info")
                })
                if isEditing {
                    Button(action: {
                        withAnimation { isEditing = false }
                    }, label: {
                        Text("cancel")
                    })
                }
            }
            if !isEditing {
                Text(String(format: "Balance: %.1f", billConfig.balance))
                Text(String(format: "Bills Count: %d", billConfig.billCount))
                
                Button(action: {
                    quitAccount()
                }, label: {
                    Text("Quit")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(Color.neonPink)
                        .cornerRadius(10)
                })
                .frame(maxWidth: .infinity)
            } else {
                InputView(itemName: "Nickname", placeHolder: userConfig.user.nickname, text: $nickname)
            }
        }
        .padding()
        .frame(width: screen.width * 0.8)
        .background(Color.white.opacity(0.9))
        .background(FrostedGlassView(effect: UIBlurEffect(style: .light)))
        .cornerRadius(10)
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text(alertMsg))
        })
    }
    
    private func quitAccount() {
        showAccountView = false
        userConfig.clear()
        billConfig.clear()
        login = false
    }
    
    private func saveOrEdit() {
        if isEditing {
            if nickname != "" {
                userConfig.user.nickname = nickname
                userConfig.save()
            }
            isEditing = false
        } else {
            isEditing = true
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(showAccountView: .constant(true))
            .environmentObject(BillConfig())
            .environmentObject(UserConfig())
    }
}

struct InputView: View {
    var itemName: String
    var placeHolder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text("\(itemName) :")
                .foregroundColor(.secondary)
            TextField(placeHolder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}
