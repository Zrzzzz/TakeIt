//
//  LoginView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/5/27.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userConfig: UserConfig
    @EnvironmentObject var billConfig: BillConfig
    @State private var showAlert: Bool = false
    @State private var alertMsg: String = ""
    @AppStorage("login") var login: Bool = false
    @AppStorage("pn") var pn: String = ""
    
    
    @State private var findingPasswd: Bool = false
    @State private var phonenumber: String = ""
    @State private var vericode: String = ""
    @State private var waittime: Int = 0
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Image("notebook")
                    .resizable()
                    .frame(width: 200, height: 200)
                
                TextField("Phonenumber", text: $phonenumber)
                    .modifier(TFModifier())
                
                
                HStack {
                    TextField("Verification Code", text: $vericode)
                        .modifier(TFModifier())
                    
                    Button(action: sendCode, label: {
                        Text(waittime <= 0 ? "Send\nCode" : "Wait\n\(waittime)s")
                            .modifier(BtnModifier())
                            .font(.system(size: 12))
                    })
                    .disabled(phonenumber == "" || waittime > 0)
                }
                
                Button(action: loginAccount, label: {
                    Text("Sign In & Log In")
                        .modifier(BtnModifier())
                })
            }
            .padding(.horizontal, 40)
            .frame(width: screen.width * 0.8, height: screen.height * 0.6)
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2, green: 0.3960784314, blue: 0.5411764706, alpha: 1)), Color(#colorLiteral(red: 0.9647058824, green: 0.6823529412, blue: 0.1764705882, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text(alertMsg))
        })
    }
    
    private func loginAccount() {
        guard phonenumber != "" else {
            showAlert = true
            alertMsg = "Please fill in phonenumber."
            return
        }
        guard vericode != "" else {
            showAlert = true
            alertMsg = "Please fill in verification code."
            return
        }
        
        guard vericode == "1234" else {
            showAlert = true
            alertMsg = "Verification code is not right."
            return
        }
        let users = DataStorage.retreive("user_data", from: .caches, as: [User].self) ?? []
        if let idx = users.firstIndex(where: { $0.phoneNumber == phonenumber }) {
            userConfig.user = users[idx]
        } else {
            userConfig.user.nickname = "User" + phonenumber
            userConfig.user.phoneNumber = phonenumber
            userConfig.save()
        }
        login = true
        userConfig.save()
        pn = phonenumber
        billConfig.loadData(userPhoneNumber: phonenumber)
    }
    
    private func sendCode() {
        waittime = 30
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true, block: {
            if waittime > 0 {
                waittime -= 1
            } else {
                $0.invalidate()
            }
        })
    }
}

private struct TFModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .disableAutocorrection(true)
            .frame(height: 50)
            .padding(.horizontal, 2)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(UIColor.separator), lineWidth: 1)
            )
    }
}

private struct BtnModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(height: 40)
            .padding(.horizontal, 20)
            .background(Color(#colorLiteral(red: 0.9490196078, green: 0.3921568627, blue: 0.09803921569, alpha: 1)))
            .cornerRadius(10)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserConfig())
            .environmentObject(BillConfig())
    }
}
