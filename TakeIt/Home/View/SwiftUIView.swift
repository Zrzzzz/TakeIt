//
//  SwiftUIView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/25.
//

import SwiftUI

struct Test: Hashable {
    var id = UUID()
    var value: Int = 0
    
    init (value: Int) {
        id = .init()
        self.value = value
    }
}

struct SwiftUIView: View {
    @State var tests: [Test] = [
    ]
    private let cols = [GridItem(.flexible()), GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        VStack {
            Button(action: {
                let idx = Int.random(in: 0..<10)
                tests[idx].value += 2
            }, label: {
                Text("Button")
            })
            
            ScrollView {
                LazyVGrid(columns: cols, content: {
                    ForEach(tests, id: \.self) { test in
                        VStack {
                            Text(test.id.description)
                            Text(test.value.description)
                        }
                        .padding()
                    }
                    Text("")
                })
            }
        }
        .onAppear {
            for i in 0..<10 {
                tests.append(Test(value: i))
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
