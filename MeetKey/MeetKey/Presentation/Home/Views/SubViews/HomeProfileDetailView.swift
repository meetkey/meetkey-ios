import SwiftUI

struct HomeProfileDetailView: View {
    @ObservedObject var homeVM: HomeViewModel
    let size: CGSize
    let safeArea: EdgeInsets
    var animation: Namespace.ID

    var body: some View {
        if let user = homeVM.currentUser {
            ZStack(alignment: .bottomLeading) {
                backgroundImageView(size: size, imageUrl: user.profileImage)
                    .ignoresSafeArea()
                VStack(spacing: 15) {

                    mainProfileImage(user: user)
                        .zIndex(1)
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 15) {

                            languageSection(user: user)

                            interestSection(user: user)

                            personalitySection(user: user)

                            bioSection(bio: user.bio ?? "소개글이 없습니다.")
                        }
                        .padding(.top, 15)
                        .padding(.bottom, 25)
                        .padding(.horizontal, 20)
                    }
                }
                .background(Color.white01)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 20)
                .padding(.top, safeArea.top + 15)
                .padding(.bottom, safeArea.bottom + 20)
            }
        }
    }
}

// MARK: - [Private Components] UI 부품들
extension HomeProfileDetailView {

    @ViewBuilder
    private func backgroundImageView(size: CGSize, imageUrl: String)
        -> some View
    {
        AsyncImage(url: URL(string: imageUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.black.opacity(0.1)
        }
        .frame(width: size.width)
        .clipped()
        .blur(radius: 30)
        .overlay(Color.black.opacity(0.2))
        .opacity(0.6)
    }

    private func mainProfileImage(user: User) -> some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: user.profileImage)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .matchedGeometryEffect(id: "profile_card", in: animation)
                } else {
                    Color.gray.opacity(0.1)
                }
            }
            .frame(width: size.width - 40, height: 330)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(alignment: .topTrailing) {
                if let badgeData = user.badge {
                    homeBadgeView(score: badgeData.totalScore)
                }
            }
            userInfoSection(user: user)
        }
    }

    private func userInfoSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                Text("\(user.name)")
                    .font(.meetKey(.title2))
                    .foregroundStyle(Color.white01)
                Text("\(user.ageInt)")
                    .font(.meetKey(.title6))
                    .foregroundStyle(Color.white01)
                Spacer()
            }
            HStack(alignment: .top, spacing: 6) {
                Image("location_home")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                Text("\(user.location), \(user.distance ?? "??") 근처")
                    .font(.meetKey(.body5))
            }
            .foregroundStyle(Color.white01.opacity(0.8))

            HStack(alignment: .top, spacing: 6) {
                Image("circle_home")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                Text(
                    "출신 국가: \(user.homeTown ?? "정보 없음") / 성별: \(user.genderDisplayName)"
                )
                .font(.meetKey(.body5))
                .lineLimit(1)
            }
            .foregroundStyle(Color.white01.opacity(0.8))
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
    }

    private func languageSection(user: User) -> some View {
        HStack(alignment: .top, spacing: 0) {
            languageCard(
                title: "사용 언어",
                language: user.nativeLanguageDisplayName,
                nation: user.nativeNation,
                level: nil
            )

            Rectangle()
                .fill(Color.black04)
                .frame(width: 1)
                .padding(.vertical, 16)

            languageCard(
                title: "관심 언어",
                language: user.targetLanguageDisplayName,
                nation: user.targetNation,
                level: user.levelDisplayName
            )
        }
        .background(Color.background1)
        .clipShape(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
        )
    }

    private func interestSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("관심사").font(.meetKey(.body2))

            let displayInterests = user.interestsDisplayNames
            if !displayInterests.isEmpty {
                let rows = generateRows(
                    interests: displayInterests,
                    screenWidth: size.width - 40
                )

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(row, id: \.self) { item in
                                interestChip(item)
                            }
                        }
                    }
                }
            }
        }
    }

    private func personalitySection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("내 성향")
                .font(.meetKey(.body1))
                .foregroundStyle(Color.text1)

            if user.personalities != nil {
                VStack(spacing: 0) {
                    personalityRow(title: "성격", value: user.socialDisplayName)
                    personalityRow(
                        title: "선호 만남",
                        value: user.meetingDisplayName
                    )
                    personalityRow(title: "대화 스타일", value: user.chatDisplayName)
                    personalityRow(
                        title: "친구 유형",
                        value: user.friendDisplayName
                    )
                    personalityRow(
                        title: "선호 관계",
                        value: user.relationDisplayName
                    )
                }
                .background(Color.gray.opacity(0.05))
                .cornerRadius(15)
            }
        }
    }

    private func bioSection(bio: String) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("한 줄 소개")
                .font(.meetKey(.body1))
                .foregroundStyle(.text1)
            Text(bio)
                .font(.meetKey(.body5))
                .foregroundStyle(Color.text3)
                .lineSpacing(6)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.background1)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

// MARK: - [Helper Views] 반복되는 작은 디자인 컴포넌트들
extension HomeProfileDetailView {

    private func interestChip(_ text: String) -> some View {
        Text(text)
            .font(.meetKey(.body2))
            .foregroundStyle(Color.main)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .background(Color.bubble31, in: Capsule())
            .overlay(alignment: .center) {
                Capsule()
                    .stroke(.main, lineWidth: 1)
            }
    }

    private func languageCard(
        title: String,
        language: String,
        nation: Nation?,
        level: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.meetKey(.body5)).foregroundStyle(Color.text3)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(language).font(.meetKey(.title5))
                    if let flagImage = nation?.image {
                        flagImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 12)
                    } else {
                        Text("??")
                    }
                }

                if let level = level {
                    Text(level)
                        .font(.meetKey(.body4))
                        .foregroundStyle(Color.main)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.sub1)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func personalityRow(title: String, value: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .foregroundStyle(Color.text3)
                    .font(.meetKey(.body5))
                Spacer()
                Text(value)
                    .font(.meetKey(.body4))
                    .foregroundStyle(Color.text2)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            Divider().padding(.horizontal, 15)
        }
    }
}

extension HomeProfileDetailView {
    @ViewBuilder
    private func homeBadgeView(score: Int) -> some View {
        let type = BadgeType1.from(score: score)
        let tagName = type.assetName.replacingOccurrences(
            of: "Badge",
            with: "Tag"
        )
        HStack {
            Image(tagName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 25)
        }
        .padding()
    }
}

extension HomeProfileDetailView {
    private func generateRows(interests: [String], screenWidth: CGFloat)
        -> [[String]]
    {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var totalWidth: CGFloat = 0
        for interest in interests {
            let font = UIFont(name: "Pretendard-Medium", size: 16)
            let attributes = [NSAttributedString.Key.font: font]
            let size = (interest as NSString).size(
                withAttributes: attributes as [NSAttributedString.Key: Any]
            )
            let chipWidth = size.width + 24 + 8
            if totalWidth + chipWidth > screenWidth {
                rows.append(currentRow)
                currentRow = [interest]
                totalWidth = chipWidth
            } else {
                currentRow.append(interest)
                totalWidth += chipWidth
            }
        }
        if !currentRow.isEmpty { rows.append(currentRow) }
        return rows
    }
}
