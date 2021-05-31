//
//  LoginView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/5/27.
//

import SwiftUI

struct LoginView: View {
    @State private var phoneNumber: String = ""
    @State private var passwd: String = ""
    @Binding var userToken: String
    
    var body: some View {
        VStack {
            VStack {
                VStack(spacing: 20) {
                    Image("notebook")
                        .resizable()
                        .frame(width: 200, height: 200)
                    
                    TextField("手机号", text: $phoneNumber)
                        .modifier(TFModifier())
                    
                    
                    SecureField("密码", text: $passwd)
                        .modifier(TFModifier())
                    
                    Button(action: login, label: {
                        Text("注册 & 登录")
                            .modifier(BtnModifier())
                    })
                }
                .padding(.horizontal, 40)
            }
            .frame(width: screen.width * 0.8, height: screen.height * 0.6)
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2, green: 0.3960784314, blue: 0.5411764706, alpha: 1)), Color(#colorLiteral(red: 0.9647058824, green: 0.6823529412, blue: 0.1764705882, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private func login() {
        let userToken = UUID().uuidString
        self.userToken = userToken
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
        LoginView(userToken: .constant(""))
    }
}
