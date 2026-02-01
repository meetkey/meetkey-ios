//
//  HeaderOverlay.swift
//  MeetKey
//
//  Created by 전효빈 on 1/26/26.
//

import SwiftUI

enum HeaderType {
    case home
    case chat
    case detail
}

struct HeaderOverlay: View {
    let state: HeaderType
    let safeArea: EdgeInsets
    let user: User
    
    var onBackAction: () -> Void
    var onFilterAction: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. 배경 처리
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
                .frame(height: safeArea.top + 15) // 높이를 여유 있게 조절

            // 2. 버튼 및 콘텐츠 레이어
            HStack(alignment: .center) {

                Group {
                    switch state {
                    case .home:
                        homeProfileCircle
                    case .detail:
                        backButton(icon: "arrow.left")
                    case .chat:
                        backButton(icon: "xmark")
                    }
                }
                .frame(width: 40, height: 40) // 크기 통일
                
                // 중앙 텍스트 (홈 모드일 때만 보임)
                if state == .home {
                    homeHeaderText
                        .padding(.leading, 8)
                } else if state == .chat {

                    Spacer()
                    Text(user.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // 오른쪽 버튼 영역
                rightSideButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - 서브 컴포넌트
extension HeaderOverlay {
    
    // 공통 버튼 스타일 (상세 뒤로가기 & 채팅 X버튼)
    private func backButton(icon: String) -> some View {
        Button(action: { onBackAction() }) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 40, height: 40) // Circle 크기와 동일하게
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())
        }
    }

    // 홈 프로필 서클
    private var homeProfileCircle: some View {
        Circle()
            .frame(width: 40, height: 40)
            .foregroundColor(.gray.opacity(0.3))
            .overlay(Text(String(user.name.prefix(1))).foregroundColor(.white))
    }

    // 홈 텍스트
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
    
    // 오른쪽 버튼 분기 (필터 vs 신고)
    private var rightSideButton: some View {
        Group {
            if state == .home || state == .detail {
                FilterButton {
                    withAnimation(.spring()) { onFilterAction() }
                }
            } else if state == .chat {
                // 신고 버튼 (점 세개)
                Button(action: { onFilterAction() }) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                }
            }
        }
    }
}
