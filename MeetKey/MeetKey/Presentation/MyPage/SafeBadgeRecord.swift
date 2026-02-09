//
//  SafeBadgeRecord.swift
//  MeetKey
//
//  Created by sumin Kong on 1/29/26.
//

import SwiftUI

struct SafeBadgeRecord: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("SAFE 뱃지 기록")
                    .font(.meetKey(.title5))
                    .foregroundColor(.text1)
                Spacer()
                Image(.x)
                    .onTapGesture {
                        dismiss()
                    }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            Divider()
            Badge(score: 90)
                .padding(.top, 40)
                .padding(.horizontal, 20)
            VStack(alignment: .leading) {
                Text("점수 기록")
                    .font(.meetKey(.body1))
                    .foregroundColor(.text1)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                ScrollView {
                    ScoreHistory()
                    ScoreHistory()
                    ScoreHistory()
                    ScoreHistory()
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .clipShape(
            MyRoundedCorner(
                radius: 20,
                corners: [.topLeft, .topRight]
            )
        )
        .navigationBarBackButtonHidden()
    }
}
