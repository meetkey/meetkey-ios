//
//  Language.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct Language: View {
    @Binding var usingLanguage: String
    @Binding var interestingLanguage: String
    @State private var isSetting: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                header(title: "사용 언어")
                
                languageContent(text: $usingLanguage)
            }
            .padding(.leading, 20)
            
            
            Spacer()
            Divider()
                .frame(height: 87)
            VStack(alignment: .leading, spacing: 0) {
                header(title: "관심 언어", showEdit: true)
                
                languageContent(text: $interestingLanguage)
            }
            .padding(.leading, 20)
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .frame(height: 115)        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSetting ? .clear : .background1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSetting ? .disabled : .clear,
                    lineWidth: isSetting ? 1 : 0
                )
        )
    }
}

private extension Language {
    func header(title: String, showEdit: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.meetKey(.body5))
                .foregroundStyle(.text3)
                .padding(.top, 14)
            
            Spacer()
            
            if showEdit {
                Image(.edit)
                    .padding(.trailing, 10)
                    .onTapGesture {
                        withAnimation {
                            isSetting.toggle()
                        }
                    }
            }
        }
    }
}

private extension Language {
    func languageContent(
        text: Binding<String>
    ) -> some View {
        
        let nation = Nation.from(serverValue: text.wrappedValue)
        
        return HStack {
            if isSetting {
                TextField("언어 입력", text: text)
                    .font(.meetKey(.title5))
                    .foregroundStyle(.text1)
                    .textFieldStyle(.plain)
                    .onChange(of: text.wrappedValue) { newValue in
                        let completed = Nation.autoComplete(from: newValue)
                        if text.wrappedValue != completed {
                            text.wrappedValue = completed
                        }
                    }
                
            } else {
                Text(text.wrappedValue)
                    .font(.meetKey(.title5))
                    .foregroundStyle(.text1)
            }
            if let nation {
                nation.image
                    .padding(.top, 8)
                    .padding(.trailing, 12)
            }
        }
        .padding(.top, 12)
    }
}
