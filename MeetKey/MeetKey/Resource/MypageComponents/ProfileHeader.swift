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
    
    private var usingLanguageImage: Image? {
        Nation.from(serverValue: user.first)?.image
    }
    
    private var interestingLanguageImage: Image? {
        Nation.from(serverValue: user.target)?.image
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
            }
            HStack(spacing: 20) {
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
                .padding(.bottom, 21)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 3.5) {
                        Text(user.name)
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
