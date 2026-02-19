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
    @Binding var path: NavigationPath
    @Binding var isTabBarHidden: Bool
    
    @State private var isEditProfilePresented = false
    @State private var showAccountMenu = false
    @State private var showLogoutModal = false
    @State private var showWithdrawModal = false
    @State private var withdrawInput = ""
    @State private var showLogoutErrorAlert = false
    @State private var showWithdrawErrorAlert = false
    
    
    var body: some View {
        
        Group {
            if let user = viewModel.user {
                ProfileContentView(
                    user: user,
                    viewModel: viewModel,
                    isTabBarHidden: $isTabBarHidden,
                    isEditProfilePresented: $isEditProfilePresented,
                    showAccountMenu: $showAccountMenu,
                    showWithdrawErrorAlert: $showWithdrawErrorAlert,
                    showLogoutErrorAlert: $showLogoutErrorAlert,
                    showAccountMenuAction: { showAccountMenu = true },
                    onRoute: { route in
                        isTabBarHidden = true
                        path.append(route)
                    }
                )
            } else {
                ProgressView("프로필 불러오는 중...")
            }
        }
        
        .navigationDestination(for: MyProfileRoute.self) { route in
            switch route {
            case .badge:
                if let badgeInfo = user.badge {
                    SafeBadgeRecord(badge: BadgeDTO(from: badgeInfo))
                } else {
                    EmptyView()
                }
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
                PersonalityEditView(
                    viewModel: PersonalityEditViewModel()
                )
            }
        }
        .onAppear {
            viewModel.fetchMyProfile()
            isTabBarHidden = false
        }
        .overlay {
            if showAccountMenu {
                AccountMenuOverlay(
                    onDismiss: { showAccountMenu = false },
                    onLogout: {
                        showAccountMenu = false
                        showLogoutModal = true
                    },
                    onWithdraw: {
                        showAccountMenu = false
                        withdrawInput = ""
                        showWithdrawModal = true
                    }
                )
            }
        }
        .overlay {
            if showLogoutModal {
                LogoutModalOverlay(
                    isLoading: viewModel.isLoggingOut,
                    onDismiss: { showLogoutModal = false },
                    onConfirm: {
                        Task {
                            await requestLogout()
                            if viewModel.logoutErrorMessage == nil {
                                showLogoutModal = false
                            }
                        }
                    }
                )
            }
        }
        .overlay {
            if showWithdrawModal {
                WithdrawModalOverlay(
                    inputText: $withdrawInput,
                    isEnabled: withdrawInput == "탈퇴합니다",
                    isLoading: viewModel.isWithdrawing,
                    onDismiss: { showWithdrawModal = false },
                    onConfirm: {
                        Task {
                            await requestWithdraw()
                            if viewModel.withdrawErrorMessage == nil {
                                showWithdrawModal = false
                            }
                        }
                    }
                )
            }
        }
    }
    
    private func push(_ route: MyProfileRoute) {
        isTabBarHidden = true
        path.append(route)
    }
    
    private func requestWithdraw() async {
        await viewModel.withdraw()
    }
    
    private func requestLogout() async {
        await viewModel.logout()
    }
}

private struct ProfileContentView: View {
    let user: User
    @ObservedObject var viewModel: MyProfileViewModel
    @Binding var isTabBarHidden: Bool
    @Binding var isEditProfilePresented: Bool
    @Binding var showAccountMenu: Bool
    @Binding var showWithdrawErrorAlert: Bool
    @Binding var showLogoutErrorAlert: Bool
    let showAccountMenuAction: () -> Void
    let onRoute: (MyProfileRoute) -> Void
    
    var body: some View {
        ScrollView {
            ProfileHeader(
                user: user,
                onTapSetting: {
                    viewModel.getMyProfileForEdit {
                        isEditProfilePresented = true
                    }
                },
                onTapNotification: showAccountMenuAction,
                onTapProfileImage: {
                    viewModel.getMyProfileForEdit {
                        isEditProfilePresented = true
                    }
                }
            )
            
            HStack(spacing: 0) {
                VStack(spacing: 18) {
                    Section(title: "내 평판", isMore: false)
                        .padding(.top, 5)
                    Recommend(recommend: user.recommendCount ?? 0, notRecommend: user.notRecommendCount ?? 0)
                    Section(title: "SAFE 뱃지 점수", isMore: true, onTapMore: {
                        onRoute(.badge)
                    })
                    .padding(.top, 5)
                    Badge(score: user.badge?.totalScore ?? 0)
                    BadgeNotice()
                    Section(title: "관심사", isMore: true, onTapMore: {
                        onRoute(.interest)
                    })
                    TagFlowLayout {
                        ForEach(user.interests ?? [], id: \.self) { i in
                            InterestTag(title: "#\(i)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Section(title: "내 성향", isMore: true, onTapMore: {
                        onRoute(.personality)
                    })
                    
                    Tendency(personality: "성격", value: viewModel.socialTypeText)
                    Tendency(personality: "선호하는 만남 방식", value: viewModel.meetingTypeText)
                    Tendency(personality: "대화 스타일", value: viewModel.chatTypeText)
                    Tendency(personality: "친구 유형", value: viewModel.friendTypeText)
                    Tendency(personality: "관계 목적", value: viewModel.relationTypeText, isLineHidden: true)
                    
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
        .navigationBarBackButtonHidden(true)
        .alert("회원탈퇴 실패", isPresented: $showWithdrawErrorAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.withdrawErrorMessage ?? "")
        }
        .alert("로그아웃 실패", isPresented: $showLogoutErrorAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.logoutErrorMessage ?? "")
        }
        .sheet(isPresented: $isEditProfilePresented) {
            if let user = viewModel.user {
                ProfileSettingView(user: user) { editedUser in
                    viewModel.user = editedUser
                }
            }
        }
        .onChange(of: isEditProfilePresented) { isPresented in
            if !isPresented {
                viewModel.fetchMyProfile()
            }
        }
        .onChange(of: viewModel.withdrawErrorMessage) { _, message in
            showWithdrawErrorAlert = (message != nil)
        }
        .onChange(of: viewModel.logoutErrorMessage) { _, message in
            showLogoutErrorAlert = (message != nil)
        }
    }
}

private struct AccountMenuOverlay: View {
    let onDismiss: () -> Void
    let onLogout: () -> Void
    let onWithdraw: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 0) {
                Button(action: onLogout) {
                    HStack(spacing: 10) {
                        Image("logout")
                            .renderingMode(.template)
                            .foregroundStyle(.text2)
                        Text("로그아웃")
                            .font(.meetKey(.body2))
                            .foregroundStyle(.text1)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                
                Divider()
                
                Button(action: onWithdraw) {
                    HStack(spacing: 10) {
                        Image("remove")
                            .renderingMode(.template)
                            .foregroundStyle(Color.meetKey.error)
                        Text("회원 탈퇴")
                            .font(.meetKey(.body2))
                            .foregroundStyle(Color.meetKey.error)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.trailing, 20)
            .padding(.top, 110)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        }
    }
}

private struct LogoutModalOverlay: View {
    let isLoading: Bool
    let onDismiss: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.text3)
                    }
                }
                
                Image("logout_char")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                
                Text("로그아웃")
                    .font(.meetKey(.title4))
                    .foregroundStyle(.text1)
                
                Text("정말 로그아웃 하시겠습니까?")
                    .font(.meetKey(.body3))
                    .foregroundStyle(.text3)
                
                HStack(spacing: 12) {
                    Button(action: onDismiss) {
                        Text("취소")
                            .font(.meetKey(.body2))
                            .foregroundStyle(.text3)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.meetKey.black04.opacity(0.4))
                            .cornerRadius(22)
                    }
                    
                    Button(action: onConfirm) {
                        Text("나가기")
                            .font(.meetKey(.body2))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.meetKey.main)
                            .cornerRadius(22)
                    }
                    .disabled(isLoading)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(24)
            .padding(.horizontal, 40)
        }
    }
}

private struct WithdrawModalOverlay: View {
    @Binding var inputText: String
    let isEnabled: Bool
    let isLoading: Bool
    let onDismiss: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 14) {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.text3)
                    }
                }
                
                Image("remove_char")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                
                Text("회원 탈퇴")
                    .font(.meetKey(.title4))
                    .foregroundStyle(.text1)
                
                Text("탈퇴 시 모든 데이터가 삭제되며\n복구할 수 없습니다.")
                    .font(.meetKey(.body3))
                    .foregroundStyle(.text3)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 8) {
                    Image("danger")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("회원탈퇴 시 채팅 기록, SAFE 뱃지, 추천 내역 등 모든 정보가 영구적으로 삭제됩니다. 삭제된 데이터는 복구할 수 없습니다.")
                        .font(.meetKey(.caption3))
                        .foregroundStyle(.text3)
                }
                .padding(12)
                .background(Color.meetKey.black04.opacity(0.15))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("확인을 위해 “탈퇴합니다”를 입력해주세요.")
                        .font(.meetKey(.caption2))
                        .foregroundStyle(.text3)
                    
                    TextField("탈퇴합니다", text: $inputText)
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(Color.meetKey.white01)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.meetKey.black04, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 6)
                
                BottomActionButton(
                    title: "탈퇴하기",
                    isEnabled: isEnabled
                ) {
                    onConfirm()
                }
                .padding(.top, 4)
                .disabled(isLoading)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(24)
            .padding(.horizontal, 24)
        }
    }
}
