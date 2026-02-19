// OtherProfile.swift
// MeetKey
//
// Created by sumin Kong on 1/30/26.

import SwiftUI

struct OtherProfile: View {
    
    @Environment (\.dismiss) private var dismiss
    @StateObject private var viewModel = OtherProfileViewModel()
    let targetId: Int
    
    var body: some View {
        ZStack(alignment: .top) {
            contentView
                .background(backgroundView)
                    .overlay(headerView, alignment: .top)
                    .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.fetchOtherProfile(targetId: targetId)
        }
        .navigationBarBackButtonHidden()
    }
    
    
    @ViewBuilder
    private var backgroundView: some View {
        Group {
            if let profile = viewModel.profile {
                AsyncImage(url: URL(string: profile.profileImage ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(.otherProfile)
                        .resizable()
                        .scaledToFill()
                }
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .ignoresSafeArea()
    }

    
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView("프로필 불러오는 중..")
                .progressViewStyle(.circular)
        }
        
        if let profile = viewModel.profile {
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 0) {
                    mainProfileImage(profile: profile)
                    
                    VStack(alignment: .leading, spacing: 18) {
                        Recommend(
                            recommend: viewModel.recommendCount,
                            notRecommend: viewModel.notRecommendCount,
                            isRecommended: viewModel.isRecommended,
                            isNotRecommended: viewModel.isNotRecommended,
                            onRecommendTap: {
                                viewModel.toggleRecommend(targetId: targetId)
                            },
                            onNotRecommendTap: {
                                viewModel.toggleNotRecommend(targetId: targetId)
                            }
                        )
                        .padding(.top, 25)
                        
                        Section(title: "SAFE 뱃지 점수", isMore: false)
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
                            .padding(.bottom, 25)
                    }
                    .padding(.horizontal, 20)
                    }
                    .background(.white01)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.top, 20)
                    .padding(.bottom, 187)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 120)
        }
    }
}


private extension OtherProfile {
    
    private var headerView: some View {
        HeaderOverlay (
            state: .otherProfile,
            user: viewModel.headerUser ?? User.me, reportVM: viewModel.reportVM,
            onLeftAction: {dismiss()},
            onRightAction: {
                viewModel.reportVM.handleReportMenuTap()
            }
        )
        .zIndex(1)
    }
    
    @ViewBuilder
    func mainProfileImage(profile: OtherInfoDTO) -> some View {
        ZStack(alignment: .bottomLeading) {
            
            AsyncImage(url: URL(string: profile.profileImage ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(.otherProfile)
                    .resizable()
                    .scaledToFill()
            }
            .frame(height: 350)
            .frame(width: UIScreen.main.bounds.width-40)
            userInfoSection(profile: profile)
                .padding(.leading, 16)
                .padding(.bottom, 16)
            
            if let _ = profile.badge?.badgeName {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        BadgeView(score: profile.badge?.totalScore ?? 0)
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func userInfoSection(profile: OtherInfoDTO) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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
            HStack {
                Image(.moreCircle)
                Text("출신국가 : \(profile.homeTown) / 성별 : \(genderText(profile.gender))")
                    .font(.meetKey(.body5))
                    .foregroundStyle(.background2)
            }
        }
    }
    
    @ViewBuilder
    func BadgeView(score: Int) -> some View {
        let type = BadgeType1.from(score: score)
        let tagName = type.assetName.replacingOccurrences(of: "Badge", with: "Tag")
        
        Image(tagName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 25)
            .padding()
    }
    
    func genderText(_ gender: String) -> String {
        gender == "MALE" ? "남성" : "여성"
    }
}

#Preview {
    OtherProfile(targetId: 1)
}
