//
//  Section.swift
//  MeetKey
//
//  Created by sumin Kong on 1/22/26.
//

import SwiftUI

struct Section: View {
    var title: String
    var isMore: Bool = true
    var onTapMore: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(.meetKey(.body1))
                .foregroundColor(.primary)
            Spacer()
            if isMore, let action = onTapMore {
                Button(action: action) {
                    Image(.more)
                }
                .buttonStyle(PlainButtonStyle()) // 기본 버튼 스타일 제거
            }
        }
        .frame(height: 24)
    }
}
