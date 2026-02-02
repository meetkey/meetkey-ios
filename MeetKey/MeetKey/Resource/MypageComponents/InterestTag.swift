//
//  InterestTag.swift
//  MeetKey
//
//  Created by sumin Kong on 1/21/26.
//

import SwiftUI

struct InterestTag: View {
    var title: String = "외향적"
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                .bubble31,
                .bubble32
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
        
    var body: some View {
            Text(title)
                .font(.meetKey(.body2))
                .foregroundStyle(.bubble31)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(gradient)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(.main, lineWidth: 1)
                )
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    InterestTag()
}
