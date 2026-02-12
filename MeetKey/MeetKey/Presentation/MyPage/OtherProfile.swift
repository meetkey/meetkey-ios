//
//  OtherProfile.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct OtherProfile: View {
    
    @StateObject private var viewModel = OtherProfileViewModel()
    let targetId: Int
    
    var body: some View {
        ZStack {
            if let profile = viewModel.profile,
               let url = URL(string: profile.profileImage) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }placeholder: {
                    ProgressView()
                }
            }else {
                Color.gray.opacity(0.2)
                    .ignoresSafeArea()
            }
            
            if viewModel.isLoading {
                ProgressView("프로필 불러오는 중..")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if let profile = viewModel.profile {
                ScrollView {
                    Image(.SAFE)//네비바 임시대체뷰
                        .frame(height: 132)
                    VStack(spacing: 0) {
                        ZStack(alignment: .bottomLeading) {
                            AsyncImage(url: URL(string: profile.profileImage ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(.otherProfile)
                                    .resizable()
                            }
                            .frame(height: 350)
                            
                            badgeImage(for: profile.badge?.badgeName ?? "")
                                .padding(.bottom, 304)
                                .padding(.leading, 282)
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 0) {
                                    Text(profile.name)
                                        .font(.meetKey(.title2))
                                        .foregroundStyle(.white01)
                                    Text("\(profile.age)")
                                        .font(.meetKey(.title6))
                                        .foregroundStyle(.white01)
                                        .padding(.leading, 4)
                                }
                                HStack {
                                    Image(.location)
                                    Text("\(profile.location), \(profile.distance)")
                                        .font(.meetKey(.body5))
                                        .foregroundStyle(.background2)
                                }
                                .padding(.top, 10)
                                .padding(.bottom, 2)
                                HStack {
                                    Image(.moreCircle)
                                    Text("출신국가 : \(profile.homeTown) / 성별 : \(genderText(profile.gender))")
                                        .font(.meetKey(.body5))
                                        .foregroundStyle(.background2)
                                }
                            }
                            .padding(.leading, 19)
                            .padding(.bottom, 24)
                            
                            
                        }
                        VStack(spacing: 18) {
                            Recommend(recommend: profile.recommendCount,
                                      notRecommend: profile.notRecommendCount)
                            Section(title: "SAFE 뱃지 점수", isMore: false)
                                .padding(.top, 5)
                            Badge(score: profile.badge?.totalScore ?? 0)
                            Section(title: "사용 언어", isMore: false)
                            Language(
                                usingLanguage: .constant(profile.first),
                                interestingLanguage: .constant(profile.target)
                            )
                            Section(title: "관심사", isMore: false)
                            
                            LazyVGrid(
                                columns: Array(
                                    repeating: GridItem(.flexible(minimum: 10), spacing: 8, alignment: .leading),
                                    count: 4
                                ),
                                alignment: .leading,
                                spacing: 8
                            ) {
                                ForEach(profile.interests, id: \.self) { interest in
                                    InterestTag(title: "#\(interest)")
                                }
                            }
                            Section(title: "내 성향", isMore: false)
                            Tendency(personality: "성격", value: viewModel.socialTypeText)
                            Tendency(personality: "선호하는 만남 방식", value: viewModel.meetingTypeText)
                            Tendency(personality: "대화 스타일", value: viewModel.chatTypeText)
                            Tendency(personality: "친구 유형", value: viewModel.friendTypeText)
                            Tendency(personality: "관계 목적", value: viewModel.relationTypeText, isLineHidden: true)
                            
                            Section(title: "한 줄 소개", isMore: false)
                            OneLiner(introduceText: profile.bio)
                                .padding(.bottom, 7)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        
                    }
                    .background(.white01)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.top, 38)
                    .padding(.horizontal, 20)
                    
                    
                }
            }
        }
        .onAppear {
            viewModel.fetchOtherProfile(targetId: targetId)
        }
    }
}

private func genderText(_ gender: String) -> String {
    gender == "MALE" ? "남성" : "여성"
}

private func badgeImage(for name: String) -> Image {
    switch name {
    case "BRONZE": return Image(.bronzeBadge)
    case "SILVER": return Image(.silverBadge)
    case "GOLD": return Image(.goldBadge)
    case "NORMAL": return Image(.normalBadge)
    default: return Image(.normalBadge)
    }
}
