//
//  OneLinerSetting.swift
//  MeetKey
//
//  Created by sumin Kong on 1/23/26.
//

import SwiftUI

struct OneLinerSetting: View {
    @Binding var introduceText: String
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            if isEditing {
                TextField("한 줄 소개를 입력해주세요.", text: $introduceText)
                    .font(.meetKey(.body5))
                    .foregroundStyle(.text2)
                    .focused($isFocused)
            }else {
                Text(introduceText.isEmpty ? "한 줄 소개를 입력해주세요" : introduceText)
                    .font(.meetKey(.body5))
                    .foregroundStyle(.text2)
            }
            Spacer()
            Image(.edit)
                .frame(width: 24, height: 24)
                .onTapGesture {
                    isEditing = true
                    DispatchQueue.main.async {
                        isFocused = true
                    }
                }
        }
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.disabled, lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
        .onSubmit {
            isEditing = false
        }
    }
}
