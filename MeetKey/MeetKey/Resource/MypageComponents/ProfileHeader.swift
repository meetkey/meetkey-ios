//
//  ProfileHeader.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct ProfileHeader: View {
    
    let user: User
    let onTapSetting: () -> Void
    let onTapNotification: () -> Void
    let onTapProfileImage: () -> Void
    
    private var displayName: String {
        User.savedName ?? user.name
    }
    
    private var usingLanguageImage: Image? {
        Nation.from(serverValue: User.savedNativeLanguage ?? user.first)?.image
    }
    
    private var interestingLanguageImage: Image? {
        Nation.from(serverValue: User.savedTargetLanguage ?? user.target)?.image
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onTapSetting){
                    Image(.setting)
                }
                Spacer()
                Text("내 프로필")
                Spacer()
                Image(.notification)
                    .onTapGesture {
                        onTapNotification()
                    }
            }
            HStack(spacing: 20) {
                Button(action: onTapProfileImage) {
                    ZStack {
                        ProfileImage(
                            imageString: user.profileImage,
                            size: 75
                        )
                        Image(.editSquare)
                            .padding(.leading, 57)
                            .padding(.top, 57)
                    }
                    .frame(width: 75, height: 75)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 21)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 3.5) {
                        Text(displayName)
                            .font(.meetKey(.title4))
                            .foregroundStyle(.text1)
                        Image(.bronze)
                    }
                    HStack(spacing: 0) {
                        Text("사용 언어")
                            .font(.meetKey(.body3))
                            .foregroundStyle(.text2)
                            .padding(.trailing, 2)
                        usingLanguageImage
                            .padding(.trailing, 6)
                        Text("관심 언어")
                            .font(.meetKey(.body3))
                            .foregroundStyle(.text2)
                            .padding(.trailing, 2)
                        interestingLanguageImage
                    }
                    .padding(.top, 7.5)
                    HStack(spacing: 4) {
                        ForEach(user.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.meetKey(.caption2))
                                .foregroundStyle(.text3)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.bottom, 21)
                Spacer()
            }
            .padding(.top, 28)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .background(.background2)
        .clipShape(
            MyRoundedCorner(
                radius: 20,
                corners: [.bottomLeft, .bottomRight]
            )
        )
    }
}
