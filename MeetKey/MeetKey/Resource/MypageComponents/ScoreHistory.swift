//
//  ScoreHistory.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct ScoreHistory: View {
    
    let history: BadgeHistoryDTO
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    imageForReason(history.reason)
                    
                    Text(history.reason)
                        .font(.meetKey(.body4))
                        .foregroundStyle(.text2)
                }
            }
            .padding(.leading, 18)
            
            Spacer()
            
            Text(scoreText)
                .font(.meetKey(.title5))
                .foregroundStyle(history.amount >= 0 ? .main : .red)
                .padding(.trailing, 24)
        }
        .frame(height: 74)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.disabled, lineWidth: 1)
        )
        .padding(.horizontal, 2)
    }
}

private extension ScoreHistory {
    var scoreText: String {
        history.amount >= 0 ? "+\(history.amount)" : "\(history.amount)"
    }
    
    func imageForReason(_ reason: String) -> Image {
        switch reason {
        case "본인 인증":
            return Image(.shieldBadge)
        case "상세 프로필 작성 완료":
            return Image(.editBadge)
        case "활동적인 멤버":
            return Image(.memberBadge)
        case "긍정적인 평가":
            return Image(.smileBadge)
        default:
            return Image(.smileBadge)
        }
    }
}
