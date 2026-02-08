//
//  LevelTag.swift
//  MeetKey
//
//  Created by sumin Kong on 1/21/26.
//

import SwiftUI

struct LevelTag: View {
    var title: String = "초보"
    
    var body: some View {
            Text(title)
                .font(.meetKey(.body4))
                .foregroundStyle(.main)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.sub1)
                .clipShape(Capsule())
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    LevelTag()
}
