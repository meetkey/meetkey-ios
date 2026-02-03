//
//  HybinProfileSectionView.swift
//
//
//  Created by 전효빈 on 1/15/26.
//

import SwiftUI

struct ProfileSectionView: View {
    let size: CGSize
    let user: User
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // 1. 배경 사진 (화면 전체 꽉 채우기)
            Image(user.profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height) // 전체 사이즈 사용
                .clipped()
                .ignoresSafeArea() //  안전 영역 무시하고 꽉 채우기
            
            // 2. 가독성을 위한 전체 그라데이션
            LinearGradient(
                colors: [.black.opacity(0.8), .clear, .black.opacity(0.3)],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()

            // 3. 상단 및 하단 콘텐츠 레이어
            VStack(alignment: .leading, spacing: 0) {
                
                // [상단] SAFE 배지 영역
                HStack {
                    Spacer()
                    Text("✓ SAFE")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 85) // 상단 노치 고려
                .padding(.trailing, 20)
                
                Spacer() // 중간 비우기
                
                // [하단] 유저 정보 영역
                VStack(alignment: .leading, spacing: 12) {
                    
                    // 성향 태그 칩
                    HStack(spacing: 8) {
                        profileChip(text: "외향적")
                        profileChip(text: "반려동물")
                        profileChip(text: "여행")
                    }
                    
                    // 이름과 나이, 인증 마크
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(user.name)
                            .font(.system(size: 32, weight: .bold))
                        Text("\(user.age)")
                            .font(.system(size: 24, weight: .medium))
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.yellow)
                    }
                    .foregroundColor(.white)
                    
                    // 언어 및 위치 상세
                    VStack(alignment: .leading, spacing: 6) {
                        Text("사용 언어 🇺🇸   관심 언어 🇰🇷")
                            .font(.system(size: 15, weight: .semibold))
                        
                        Label("서울시 마포구, 20km 근처", systemImage: "location.fill")
                            .font(.system(size: 14))
                        
                        Text(user.bio ?? "")
                            .font(.system(size: 14))
                            .lineLimit(1)
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding(.leading, 20)
                .padding(.bottom, 140) // 하단 탭바 높이 고려
            }
        }
    }
    
    // 칩 컴포넌트
    private func profileChip(text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(15)
    }
}
