//
//  CategoryEditView.swift
//  TakeIt
//
//  Created by Zr埋 on 2021/6/10.
//

import SwiftUI

struct CategoryEditView: View {
    @Binding var categorys: [Category]
    @State private var billType: BillType = .in
    
    
    @Binding var showCategoryEditor: Bool
    
    // for adding newCategory
    @State private var addingCategory: Bool = false
    @State private var categoryName: String = ""
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation { addingCategory = true }
                }, label: {
                    Text("New Category")
                })
                
                Spacer()
                
                Button(action: { showCategoryEditor = false }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                })
            }
            
            if (addingCategory) {
                TextField("Category Name", text: $categoryName)
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            addingCategory = false
                            categoryName = ""
                        }
                    }, label: {
                        Text("cancel")
                            .foregroundColor(.secondary)
                    })
                    Button(action: {
                        withAnimation {
                            addingCategory = false
                            categorys.append(Category(icon: "", name: categoryName, type: billType, original: false))
                            categoryName = ""
                        }
                    }, label: {
                        Text("confirm")
                            .foregroundColor(.red)
                    })
                }
            }
            
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
                .pickerStyle(SegmentedPickerStyle())
            
            List {
                ForEach (categorys.filter { $0.type == billType }, id: \.self) { category in
                    HStack {
                        Text(category.name)
                        Image(category.icon)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                .onDelete { (index) in
                    let cate = categorys.filter { $0.type == billType }[index.first!]
                    guard !cate.original else {
                        showAlert = true
                        return
                    }
                    categorys.removeAll(where: { $0 == cate })
                }
            }
        }
        .padding()
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Original category CAN'T be deleted!"))
        })
    }
}

struct CategoryEditView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryEditView(categorys: .constant([
            Category(icon: "shopping", name: "shopping", type: .out, original: true),
            Category(icon: "game", name: "game", type: .out, original: true),
            Category(icon: "payoff", name: "payoff", type: .in, original: true),
            Category(icon: "standard", name: "standard", type: .out, original: true),
            Category(icon: "wage", name: "wage", type: .in, original: true),
            Category(icon: "redbag", name: "redbag", type: .in, original: true)
        ]), showCategoryEditor: .constant(true))
    }
}
