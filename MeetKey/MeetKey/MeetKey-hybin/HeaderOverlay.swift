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
//    @Binding var showDetail: Bool
    
    // ✅ type을 state로 변경
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
                .frame(height: safeArea.top + 15)

            // 2. 상태별 레이어 분기
            HStack(alignment: .center) {
                switch state {
                case .home:
                    // ✅ 홈 모드: 기존 로직 그대로 유지
                    homeHeaderItems
                    
                case .detail:
                    // ✅ 상세 모드: 뒤로가기 버튼 중심
                    detailHeaderItems
                    
                case .chat:
                    // ✅ 채팅 모드: 일단 오류 방지용 주석 및 빈 화면 처리
                    /*
                    HStack {
                        Button(action: { onBackAction() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Text(user.name) // 상대방 이름
                        Spacer()
                        Image(systemName: "ellipsis")
                    }
                    */
                    EmptyView()
                }
                
                Spacer()
                
                // 오른쪽 필터 버튼
                if state == .home || state == .detail {
                    FilterButton {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            onFilterAction()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - 서브 뷰 컴포넌트 (가독성을 위해 분리)
extension HeaderOverlay {
    
    // 홈 모드 아이템
    private var homeHeaderItems: some View {
        HStack(spacing: 12) {
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray.opacity(0.3))
                .overlay(Text(String(user.name.prefix(1))).foregroundColor(.white))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name + "님,")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                Text("이런 친구는 어때요?")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .transition(.move(edge: .leading).combined(with: .opacity))
    }
    
    // 상세 모드 아이템
    private var detailHeaderItems: some View {
        Button(action: { onBackAction() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(12)
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())
        }
        .transition(.move(edge: .leading).combined(with: .opacity))
    }
}
