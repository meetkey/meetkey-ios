//
//  Language.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct Language: View {
    var usingLanguage: String = "English"
    var interestingLanguage: String = "Korean"
    var isSetting: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 0){
                    Text("사용 언어")
                        .font(.meetKey(.body5))
                        .foregroundStyle(.black03)
                        .padding(.top, 14)
                    Spacer()
//                    if isSetting {
//                        Image(.edit)
//                            .padding(.trailing, 10)
//                    }
                }
                HStack {
                    Text(usingLanguage)
                        .font(.meetKey(.title5))
                        .foregroundStyle(.black01)
                        .padding(.trailing, 4)
                    Image(.usUnitedStates)
                        .padding(.top, 8)
                        .padding(.trailing, 12)
                }
                .padding(.top, 12)
                LevelTag()
                    .padding(.top, 4)
                    .hidden()
            }
            .padding(.leading, 20)
            
            Spacer()
            Divider()
                .frame(height: 87)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 0){
                    Text("관심 언어")
                        .font(.meetKey(.body5))
                        .foregroundStyle(.black03)
                        .padding(.top, 14)
                    Spacer()
                    if isSetting {
                        Image(.edit)
                            .padding(.trailing, 10)
                    }
                }
                HStack {
                    Text(interestingLanguage)
                        .font(.meetKey(.title5))
                        .foregroundStyle(.black01)
                        .padding(.trailing, 4)
                    Image(.krKoreaSouth)
                        .padding(.top, 8)
                        .padding(.trailing, 12)
                    
                }
                .padding(.top, 12)
                LevelTag()
                    .padding(.top, 4)
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

#Preview {
    Language()
}
