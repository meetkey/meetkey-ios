//
//  HybinMainTabView.swift
//  MeetKey
//
//  Created by 전효빈 on 1/15/26.
//

import SwiftUI

// 1. 탭 종류 정의
enum HybinTab: String, CaseIterable {
    case home = "sparkles"
    case chat = "bubble.left.and.bubble.right"
    case profile = "person"

    var title: String {
        switch self {
        case .home: return "홈"
        case .chat: return "채팅"
        case .profile: return "프로필"
        }
    }
}

struct HybinMainTabView: View {
    @State private var currentTab: HybinTab = .home
    @StateObject private var homeVM = HomeViewModel()

//    @State private var user: User?
    @State private var user = User.me
    @State private var profilePath = NavigationPath()
    @State private var isTabBarHidden = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch currentTab {
                case .home:
                    HomeView(homeVM: homeVM)
                case .chat:
                    HybinChatListView()
                case .profile:
                    NavigationStack(path: $profilePath) {
                        MyProfile(
                            user: $user,
                            path: $profilePath,
                            isTabBarHidden: $isTabBarHidden
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 3. 커스텀 탭 바
            if !homeVM.isDetailViewPresented && !isTabBarHidden {
                customTabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard)  // 키보드 올라올 때 탭 바 밀림 방지
    }

    private var customTabBar: some View {
        HStack {
            ForEach(HybinTab.allCases, id: \.self) { tab in
                Spacer()
                Button {
                    withAnimation(.spring()) { currentTab = tab }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.rawValue)
                            .font(.system(size: 20, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2)
                    }
                    .foregroundColor(currentTab == tab ? .pink : .gray)
                    .frame(maxWidth: .infinity)
                }
                Spacer()
            }
        }
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)  // 플로팅 스타일 하단 바
    }
}

// MARK: - Placeholder Views (나중에 채워넣을 뷰들)

struct HybinChatListView: View {
    var body: some View {
        NavigationStack {
            List(0..<10) { i in
                Text("채팅방 \(i + 1)")
            }
            .navigationTitle("채팅")
        }
    }
}

struct HybinMyProfileView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
            Text("내 정보 설정")
                .font(.headline)
        }
    }
}
