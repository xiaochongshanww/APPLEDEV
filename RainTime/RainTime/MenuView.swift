//
//  MenuView.swift
//  RainTime
//
//  Created by 青云子 on 2023/6/27.
//

import Foundation

import SwiftUI

struct MenuView: View {
    @Binding var isShowingMenu: Bool

    var body: some View {
        VStack {
            Text("Menu")
                .font(.title)
                .fontWeight(.bold)
            
            // 在菜单视图中添加其他内容
            
            Button(action: {
                isShowingMenu.toggle()
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}
