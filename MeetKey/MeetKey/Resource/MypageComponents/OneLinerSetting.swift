//
//  OneLinerSetting.swift
//  MeetKey
//
//  Created by sumin Kong on 1/23/26.
//

import SwiftUI

struct OneLinerSetting: View {
    var introduceText: String
    var body: some View {
        HStack(spacing: 8) {
            Image(.volume)
                .padding(.leading, 16)
            Text(introduceText)
                .font(.meetKey(.body5))
                .foregroundStyle(.text3)
                .padding(.trailing, 16)
        }
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .background(.background1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

