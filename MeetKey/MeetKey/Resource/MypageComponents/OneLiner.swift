//
//  OneLiner.swift
//  MeetKey
//
//  Created by sumin Kong on 1/23/26.
//

import SwiftUI

struct OneLiner: View {
    var introduceText: String
    var body: some View {
        HStack(spacing: 8) {
            Image(.volume)
                .padding(.leading, 16)
            Text(introduceText)
                .font(.meetKey(.body5))
                .foregroundStyle(.black03)
                .padding(.trailing, 16)
        }
        .frame(height: 56)
        .background(.background1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

