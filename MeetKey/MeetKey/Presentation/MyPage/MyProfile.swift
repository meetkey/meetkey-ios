//
//  MyProfile.swift
//  MeetKey
//
//  Created by sumin Kong on 1/29/26.
//

import SwiftUI

enum MyProfileRoute: Hashable {
    case badge
    case interest
    case personality
}

struct MyProfile: View {
    @StateObject private var viewModel = MyProfileViewModel()
    @Binding var user: User
    @State private var isEditProfilePresented = false
    @Binding var path: NavigationPath
    @Binding var isTabBarHidden: Bool
    
    var body: some View {
        
        Group {
            if let user = viewModel.user {
                profileContent(user: user)
            } else {
                ProgressView("프로필 불러오는 중...")
            }
        }
        
        .navigationDestination(for: MyProfileRoute.self) { route in
            switch route {
            case .badge:
                SafeBadgeRecord()
            case .interest:
                InterestEditView(
                    viewModel: InterestEditViewModel(
                        initialInterests: user.interests ?? []
                    ),
                    onSave: { newInterests in
                        user.interests = newInterests
                    }
                )
            case .personality:
                let initialSelections: [WritableKeyPath<Personalities, String>: String] = {
                    if let p = user.personalities {
                        return [
                            \Personalities.socialType: p.socialType,
                            \Personalities.meetingType: p.meetingType,
                            \Personalities.chatType: p.chatType,
                            \Personalities.friendType: p.friendType,
                            \Personalities.relationType: p.relationType
                        ]
                    } else {
                        return [:]
                    }
                }()

                PersonalityEditView(
                    viewModel: PersonalityEditViewModel()
                )
            }
        }
        .onAppear {
            viewModel.fetchMyProfile()
            isTabBarHidden = false
        }
    }
    
    private func profileContent(user: User) -> some View {
        ScrollView {
            ProfileHeader(user: user){
                isEditProfilePresented = true
            }
            HStack(spacing: 0) {
                VStack(spacing: 18) {
                    Section(title: "내 평판", isMore: false)
                        .padding(.top, 5)
                    Recommend(recommend: user.recommendCount ?? 0, notRecommend: user.notRecommendCount ?? 0)
                    Section(title: "SAFE 뱃지 점수", isMore: true, onTapMore: {
                        push(.badge)
                    })
                    .padding(.top, 5)
                    Badge(score: user.badge?.totalScore ?? 0)
                    BadgeNotice()
                    Section(title: "관심사", isMore: true, onTapMore: {
                        push(.interest)
                    })
                    TagFlowLayout {
                        ForEach(user.interests ?? [], id: \.self) { i in
                            InterestTag(title: "#\(i)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Section(title: "내 성향", isMore: true, onTapMore: {
                        push(.personality)
                    })
                    Tendency(personality: "성격", value: user.personalities?.socialType ?? "외향적")
                    Tendency(personality: "선호하는 만남 방식", value: user.personalities?.meetingType ?? "상관 없어요")
                    Tendency(personality: "대화 스타일", value: user.personalities?.chatType ?? "먼저 말 걸어 주세요")
                    Tendency(personality: "친구 유형", value: user.personalities?.friendType ?? "상관 없어요")
                    Tendency(personality: "관계 목적", value: user.personalities?.relationType ?? "언어 공부", isLineHidden: true)
                    Section(title: "한 줄 소개", isMore: true)
                    OneLiner(introduceText: user.oneLiner ?? "안녕하세요. 김밋키입니다! 새로운 친구를 사귀고 싶습니다. MBTI는 ENTP입니다.")
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 18)
            }
            .background(.white01)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.top, 27)
            .padding(.horizontal, 20)
            .padding(.bottom, 130)
        }
        .background(.background1)
        .ignoresSafeArea()
        .sheet(isPresented: $isEditProfilePresented) {
            ProfileSettingView(user: $user)
        }
    }
    
    private func push(_ route: MyProfileRoute) {
        isTabBarHidden = true
        path.append(route)
    }
}
