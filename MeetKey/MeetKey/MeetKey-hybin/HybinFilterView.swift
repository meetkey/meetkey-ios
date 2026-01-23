//
//  HybinFilterView.swift
//  MeetKey
//
//  Created by 전효빈 on 1/23/26.
//

import SwiftUI

struct HybinFilterView: View {
    @ObservedObject var homeVM: HybinHomeViewModel
    var onDismiss : () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Button {
                homeVM.didSelectHome()
            } label:{
                Text("go Home")
            }
            Text("필터 설정")
                .font(.headline)
                .padding(.top, 60)

            Divider()

            // 간단한 필터 항목들
            VStack(alignment: .leading) {
                Text("거리 범위").font(.caption).foregroundColor(.gray)
                Text("20km 이내").bold()
            }

            VStack(alignment: .leading) {
                Text("나이대").font(.caption).foregroundColor(.gray)
                Text("24세 - 30세").bold()
            }

            Spacer()

            Button("적용하기") {
                onDismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
}
