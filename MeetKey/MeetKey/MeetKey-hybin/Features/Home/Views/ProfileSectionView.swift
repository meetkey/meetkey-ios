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
            // 1. 배경 레이어
            backgroundLayer
            
            // 2. 콘텐츠 레이어
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 14) {
                    // 성향 태그 섹션
                    interestTagStack(interests: user.interests)
                    
                    // 이름, 나이, 뱃지 섹션 (피그마 핵심)
                    nameAndBadgeStack(name: user.name, age: user.ageInt, badge: user.badge)
                    
                    // 언어 정보 섹션
                    languageInfoStack(first: user.first, target: user.target)
                    
                    // 위치 및 소개 섹션
                    locationStack(location: user.location, distance: user.distance)
                    
                    bioStack(bio: user.bio)
                }
                .padding(.leading, 20)
                .padding(.bottom, 150) // 하단 탭바 여백 고려
            }
        }
    }
}

// MARK: - [Private Components] 하위 컴포넌트 분리
private extension ProfileSectionView {
    
    // 1. 배경 이미지 및 그라데이션
    private var backgroundLayer: some View {
        ZStack {
            Image(user.profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()
            
            LinearGradient(
                colors: [.black.opacity(0.9), .clear],
                startPoint: .bottom,
                endPoint: .center
            )
        }
        .ignoresSafeArea()
    }
    
    // 2. 성향 태그 스택
    private func interestTagStack(interests: [String]?) -> some View {
        HStack(spacing: 6) {
            if let interests = interests {
                ForEach(interests.prefix(3), id: \.self) { interest in
                    Text(interest)
                        .font(.meetKey(.body4))
                        .padding(.horizontal, 8)
                        .background(Color.text5)
                        .foregroundStyle(Color.white01)
                        .clipShape(RoundedRectangle(cornerRadius:10))
                }
            }
        }
    }
    
    // 3. 이름, 나이 및 동그란 뱃지 스택
    private func nameAndBadgeStack(name: String, age: Int, badge: BadgeInfo?) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text(name)
                .font(.system(size: 34, weight: .bold))
            Text("\(age)")
                .font(.system(size: 28, weight: .medium))
            
            if let badgeData = badge {
                let type = BadgeType1.from(score: badgeData.totalScore)
                let circleBadgeName = type.assetName.replacingOccurrences(of: "Badge", with: "")
                
                Image(circleBadgeName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
        }
        .foregroundStyle(Color.white01)
    }
    
    // 4. 언어 정보 스택
    private func languageInfoStack(first: String?, target: String?) -> some View {
        HStack(spacing: 12) {
            languageLabel(title: "사용 언어", lang: first)
            languageLabel(title: "관심 언어", lang: target)
        }
        .font(.meetKey(.body2))
        .foregroundStyle(Color.white01)
    }
    
    // 언어 정보 내의 개별 레이블 (재사용)
    private func languageLabel(title: String, lang: String?) -> some View {
        HStack(spacing: 4) {
            Text(title)
            // 국기 데이터가 모델에 있다면 연동, 없다면 텍스트 출력
            Text(lang ?? "??")
        }
    }
    
    // 5. 위치 및 한 줄 소개 스택
    private func locationStack(location: String?, distance: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("\(location ?? "서울"), \(distance ?? "??")km 근처", systemImage: "location.fill")
                .font(.system(size: 14))
        }
        .foregroundStyle(Color.white.opacity(0.8))
    }
    
    private func bioStack(bio: String?) -> some View{
        HStack(alignment: .top, spacing: 6){
            Image(systemName: "ellipsis.bubble.fill")
                .font(.system(size: 12))
                .padding(.top, 2)
            Text(bio ?? "")
                .font(.system(size: 14))
                .lineLimit(1)
        }
        .foregroundStyle(Color.white.opacity(0.8))
    }
}
