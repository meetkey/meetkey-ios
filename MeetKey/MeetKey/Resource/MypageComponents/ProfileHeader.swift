//
//  ProfileHeader.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct ProfileHeader: View {
    var profileImage: Image? = Image(.meetKeyCharacter)
    var name: String = "김밋키"
    var usingLanguage: Image? = Image(.krKoreaSouth)
    var interestingLanguages: Image? = Image(.usUnitedStates)
    var badge: Image?
    var tags: [String] = ["24살", "외향적", "반려동물", "여행"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(.setting)
                Spacer()
                Text("내 프로필")
                Spacer()
                Image(.notification)
            }
            HStack(spacing: 20) {
                ZStack {
                    profileImage?
                            .resizable()
                            .scaledToFill()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                    Image(.editSquare)
                        .padding(.leading, 57)
                        .padding(.top, 57)
                }
                .frame(width: 75, height: 75)
                .padding(.bottom, 21)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 3.5) {
                        Text(name)
                            .font(.meetKey(.title4))
                            .foregroundStyle(.black01)
                            .padding(.bottom, 3.5)
                        Image(.bronze)
                    }
                    HStack(spacing: 0) {
                        Text("사용 언어")
                            .font(.meetKey(.body3))
                            .foregroundStyle(.black06)
                            .padding(.trailing, 2)
                        usingLanguage
                            .padding(.trailing, 6)
                        Text("관심 언어")
                            .font(.meetKey(.body3))
                            .foregroundStyle(.black06)
                            .padding(.trailing, 2)
                        interestingLanguages
                    }
                    .padding(.top, 7.5)
                    HStack(spacing: 4) {
                        ForEach(tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.meetKey(.caption2))
                                .foregroundStyle(.black03)
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

#Preview {
    ProfileHeader()
}
