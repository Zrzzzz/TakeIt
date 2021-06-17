//
//  FrostedGlassView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/15.
//

import SwiftUI

struct FrostedGlassView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect
        uiView.alpha = 0.6
    }
}

struct FrostedGlassView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.yellow
                .edgesIgnoringSafeArea(.all)
            
            FrostedGlassView(effect: UIBlurEffect(style: .light))
                .edgesIgnoringSafeArea(.all)
            
            Text("Hello \nVisual Effect View")
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundColor(.white)
        }
    }
}
