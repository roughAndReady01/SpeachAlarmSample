//
//  ContentView.swift
//  SpeachAlarmSample
//
//  Created by 春蔵 on 2023/01/23.
//

import SwiftUI

struct ContentView: View {
    /// viewModel
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            TextField("話す内容", text: $viewModel.spechText)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.primary, lineWidth: 0.5)
                )
            Spacer()
            Button("アラーム設定") {
                viewModel.onSetAlaram()
            }
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.blue, lineWidth: 0.5)
            )
            
            Spacer()
        }
        .padding()
        .onAppear(){
            // 通知許可
            viewModel.requestAuthorization()
        }
    }
}
