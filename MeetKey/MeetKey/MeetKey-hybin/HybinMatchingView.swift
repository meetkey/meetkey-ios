//
//  HybinMatchingView.swift
//  MeetKey
//
//  Created by 전효빈 on 1/23/26.
//

import SwiftUI


struct HybinMatchingView: View {
    
    @ObservedObject var homeVM: HybinHomeViewModel
    var onDismiss : () -> Void
    var body: some View {
        ZStack {
            VStack {
                Button(action: {
                    homeVM.finishMatch()
                    onDismiss()
                }) {
                    Text("계속 탐색하기")
                        .font(.headline)
                        .foregroundStyle(Color.black)
                        .padding()
                        .frame(width: 250)
                }
                Color.pink.opacity(0.1)
                Text("Matching View")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
