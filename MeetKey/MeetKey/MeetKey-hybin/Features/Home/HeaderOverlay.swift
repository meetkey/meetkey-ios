//
//  HeaderOverlay.swift
//  MeetKey
//
//  Created by 전효빈 on 1/26/26.
//

import SwiftUI

enum HeaderType {
    case home             // 매칭 화면 (HomeView Header)
    case homeDetail       // 홈에서 진입한 상세 프로필
    case matchingSuccess  // Like 이후 보이는 채팅방 헤더
    
    case chat             // 일반 채팅방 헤더 (은재님 파트)
    
    case myProfile        // 나의 프로필 헤더 (수민님 파트)
    case opponentDetail   // 탭바로 들어간 상대방 프로필 디테일(수민님 파트)
}

struct HeaderOverlay: View {
    let state: HeaderType
    let user: User
    @ObservedObject var reportVM: ReportViewModel
    
    var onLeftAction: () -> Void = {}
    var onRightAction: () -> Void = {}
    var onDetailAction: () -> Void?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                defaultHeaderLayout
                    .padding(.top, 20)
                
                if reportVM.isReportMenuPresented {
                    reportMenuList(reportVM: reportVM)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .top)
            )
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - 레이아웃 핵심 로직
extension HeaderOverlay {
    
    private var defaultHeaderLayout: some View {
        HStack(alignment: .center) {
            leftArea.frame(width: 40, height: 40)
            
            if state == .home {
                homeHeaderText.padding(.leading, 8)
                Spacer()
            } else {
                Spacer()
                centerArea
                Spacer()
            }
            
            rightArea.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var leftArea: some View {
        switch state {
        case .home:
            Button(action: onLeftAction) {
                Circle().fill(.gray.opacity(0.3))
                    .overlay(Text(String(user.name.prefix(1))).foregroundColor(.white))
            }
        default:
            Button(action: onLeftAction) {
                Image(systemName: state == .chat || state == .matchingSuccess ? "xmark" : "arrow.left")
                    .font(.system(size: 18, weight: .bold)).foregroundColor(.black)
                    .frame(width: 40, height: 40).background(Color.white.opacity(0.8)).clipShape(Circle())
            }
        }
    }

    @ViewBuilder
    private var centerArea: some View {
        if state == .chat || state == .matchingSuccess {
            VStack(spacing: 4) {
                Image(user.profileImage).resizable().frame(width: 32, height: 32).clipShape(Circle())
                Text(user.name).font(.meetKey(.title5))
            }
        } else {
            Text(user.name).font(.meetKey(.title5))
        }
    }

    @ViewBuilder
    private var rightArea: some View {
        if state == .home || state == .homeDetail {
            FilterButton { withAnimation(.spring()) { onRightAction() } }
        } else {
            ellipsisButton
        }
    }
}

// MARK: - 공통 부품들
extension HeaderOverlay {
    private var homeHeaderText: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(user.name + "님,")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
            Text("이런 친구는 어때요?")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
    }

    private var ellipsisButton: some View {
        Button(action: { withAnimation(.spring()) { onRightAction() } }) {
            Image(systemName: "ellipsis").rotationEffect(.degrees(90))
                .font(.system(size: 20, weight: .bold)).foregroundColor(.black)
                .frame(width: 40, height: 40).background(Color.white.opacity(0.8)).clipShape(Circle())
        }
    }

    private func reportMenuList(reportVM: ReportViewModel) -> some View {
        VStack(spacing: 0) {
            menuItem(title: "프로필 보기", icon: "person.circle") {
                onDetailAction()
                onLeftAction()
            }
            Divider().padding(.horizontal, 10)
            menuItem(title: "차단하기", icon: "nosign") { reportVM.currentReportStep = .block }
            Divider().padding(.horizontal, 10)
            menuItem(title: "신고하기", icon: "exclamationmark.bubble", isDestructive: true) { reportVM.currentReportStep = .report }
        }

        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    private func menuItem(title: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: { withAnimation { action() } }) {
            HStack {
                Image(systemName: icon).font(.system(size: 16))
                Text(title).font(.system(size: 14, weight: .medium))
                Spacer()
            }
            .foregroundColor(isDestructive ? .red : .black)
            .padding(.vertical, 12).padding(.horizontal, 16)
        }
    }
}
