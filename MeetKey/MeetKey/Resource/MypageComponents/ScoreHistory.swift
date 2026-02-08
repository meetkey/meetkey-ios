//
//  ScoreHistory.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct ScoreHistory: View {
    var scoreImage: Image = .init(.shieldDone)
    var scoreTitle: String = "본인 인증"
    var score: Int = 20
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    scoreImage
                    Text(scoreTitle)
                        .font(.meetKey(.body4))
                        .foregroundStyle(.text2)
                }
                Text("내 위치 기반으로 등록됩니다.")
                    .font(.meetKey(.caption3))
                    .foregroundStyle(.text04)
            }
            .padding(.leading, 18)
            Spacer()
            Text("+\(score)")
                .font(.meetKey(.title5))
                .foregroundStyle(.main)
                .padding(.trailing, 24)
        }
        .frame(height: 74)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.disabled, lineWidth: 1)
        )
    }
}
