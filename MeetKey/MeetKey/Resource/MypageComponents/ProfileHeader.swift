//
//  ProfileHeader.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct ProfileHeader: View {
    
    let user: User
    let profileImageName: String
    let onTapSetting: () -> Void
    
    private var usingLanguageImage: Image? {
        Nation.from(serverValue: user.usingLanguage)?.image
    }
    
    private var interestingLanguageImage: Image? {
        Nation.from(serverValue: user.interestingLanguage)?.image
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    onTapSetting()
                } label: {
                    Image(.setting)
                }
                Spacer()
                Text("내 프로필")
                Spacer()
                Image(.notification)
            }
            HStack(spacing: 20) {
                ZStack {
                    if let uiImage = loadImageFromDocuments(profileImageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                    } else {
                        Image(profileImageName) // 에셋 fallback
                            .resizable()
                            .scaledToFill()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                    }
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
                            .padding(.bottom, 3.5)
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

extension ProfileHeader {
    func loadImageFromDocuments(_ filename: String) -> UIImage? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        return UIImage(contentsOfFile: url.path)
    }
}
