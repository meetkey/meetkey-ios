//
//  HeaderOverlay.swift
//  MeetKey
//
//  Created by 전효빈 on 1/26/26.
//

import SwiftUI


struct HeaderOverlay: View {
    @Binding var showDetail: Bool
    
    let safeArea : EdgeInsets
    let user: User
    
    var onBackAction: () -> Void
    var onFilterAction: () -> Void
    
    var body: some View {
        // 1. 헤더 전체 컨테이너 (상단 끝까지 채우기 위해 ZStack 사용)
        ZStack(alignment: .bottom) {
            
            // ✅ 배경: 상단 세이프 에리어를 무시하고 꽉 채우는 블러 효과
            // 피그마 디자인에 따라 컬러와 블러 강도를 조절하세요.
            RoundedRectangle(cornerRadius:20)
                .fill(.ultraThinMaterial) // 또는 Color.black.opacity(0.2).background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
                .frame(height: safeArea.top + 15) // 헤더 전체 높이 (노치 포함)

            // 2. 실제 버튼 및 텍스트 레이어, 하드코딩 = 현재 로그인 유저
            HStack(alignment: .center) {
                if showDetail {
                    // ✅ 상세 모드: 뒤로가기 버튼
                    Button(action: { onBackAction() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    // ✅ 홈 모드: 프로필 + 타이틀
                    HStack(spacing: 12) {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray.opacity(0.3)) // 배경색
                            .overlay(Text("효").foregroundColor(.white))
                        
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
                
                Spacer()
                
                // ✅ 필터 버튼
                FilterButton {
                    withAnimation(.spring(response: 0.4 , dampingFraction: 0.8)) {
                        onFilterAction()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12) // 바닥과의 간격
        }
        // ✅ 헤더 자체가 화면 상단에 딱 붙도록 고정
        .fixedSize(horizontal: false, vertical: true)
    }
}
