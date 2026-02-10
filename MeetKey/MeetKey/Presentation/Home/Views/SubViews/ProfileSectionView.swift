//
//  HybinProfileSectionView.swift
//
//
//  Created by 전효빈 on 1/15/26.
//

import SwiftUI

struct ProfileSectionView: View {
    let size: CGSize
    let user: User

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundLayer

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 14) {
                    interestTagStack(interests: user.interests)

                    nameAndBadgeStack(
                        name: user.name,
                        age: user.ageInt,
                        badge: user.badge
                    )

                    languageInfoStack(user: user)

                    locationStack(
                        location: user.location,
                        distance: user.distance
                    )

                    bioStack(bio: user.bio)
                }
                .padding(.leading, 20)
                .padding(.bottom, 150)  // 하단 탭바 여백 고려
            }
        }
    }
}

// MARK: - [Private Components] 하위 컴포넌트 분리
extension ProfileSectionView {

    private var backgroundLayer: some View {
        ZStack {
            Image(user.profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()

            LinearGradient(
                colors: [.black.opacity(0.9), .clear],
                startPoint: .bottom,
                endPoint: .center
            )
        }
        .ignoresSafeArea()
    }

    private func interestTagStack(interests: [String]?) -> some View {
        HStack(spacing: 6) {
            if let interests = interests {
                ForEach(interests.prefix(3), id: \.self) { interest in
                    Text(interest)
                        .font(.meetKey(.body4))
                        .padding(.horizontal, 8)
                        .background(Color.text5)
                        .foregroundStyle(Color.white01)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func nameAndBadgeStack(name: String, age: Int, badge: BadgeInfo?)
        -> some View
    {
        HStack(alignment: .center, spacing: 8) {
            Text(name)
                .font(.meetKey(.title2))
            Text("\(age)")
                .font(.meetKey(.title6))

            if let badgeData = badge {
                let type = BadgeType1.from(score: badgeData.totalScore)
                let circleBadgeName = type.assetName.replacingOccurrences(
                    of: "Badge",
                    with: ""
                )

                Image(circleBadgeName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
        }
        .foregroundStyle(Color.white01)
    }

    private func languageInfoStack(user: User) -> some View {
        HStack(spacing: 12) {
            languageLabel(title: "사용 언어", nation: user.nativeNation)
            languageLabel(title: "관심 언어", nation: user.targetNation)
        }
        .font(.meetKey(.body2))
        .foregroundStyle(Color.white01)
    }

    private func languageLabel(title: String, nation: Nation?) -> some View {
        HStack(spacing: 4) {
            Text(title)
            if let flagImage = nation?.image {
                flagImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 12)
            } else {
                Text("??")
            }
        }
    }

    private func locationStack(location: String?, distance: String?)
        -> some View
    {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                "\(location ?? "서울"), \(distance ?? "??") 근처",
                systemImage: "location.fill"
            )
            .font(.meetKey(.body5))
        }
        .foregroundStyle(Color.white01.opacity(0.8))
    }

    private func bioStack(bio: String?) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "ellipsis.bubble.fill")
                .font(.meetKey(.body5))
                .padding(.top, 2)
            Text(bio ?? "")
                .font(.meetKey(.body5))
                .lineLimit(1)
        }
        .foregroundStyle(Color.white01.opacity(0.8))
    }
}
