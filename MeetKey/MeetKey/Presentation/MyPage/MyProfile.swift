//
//  MyProfile.swift
//  MeetKey
//
//  Created by sumin Kong on 1/29/26.
//

import SwiftUI

struct MyProfile: View {
    let interests = [
        "여행", "수영", "헬스", "외국어",
        "맛집", "영화", "반려동물", "음악",
        "여행", "수영", "헬스", "외국어"
    ]

    var body: some View {
        ScrollView {
            ProfileHeader()
            HStack(spacing: 0) {
                VStack(spacing: 18) {
                    Section(title: "내 평판", isMore: false)
                        .padding(.top, 5)
                    Recommend(recommend: 165, notRecommend: 12)
                    Section(title: "SAFE 뱃지 점수", isMore: true)
                        .padding(.top, 5)
                    Badge(score: 90)
                    BadgeNotice()
                    Section(title: "관심사", isMore: true)
                    
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(minimum: 10), spacing: 8, alignment: .leading),
                            count: 4
                        ),
                        alignment: .leading,
                        spacing: 8
                    ) {
                        ForEach(interests.indices, id: \.self) { i in
                            InterestTag(title: "#\(interests[i])")
                        }
                    }
                    Section(title: "내 성향", isMore: true)
                    Tendency(personality: "성격", value: "외향적")
                    Tendency(personality: "선호하는 만남 방식", value: "상관 없어요")
                    Tendency(personality: "대화 스타일", value: "먼저 말 걸어 주세요")
                    Tendency(personality: "친구 유형", value: "상관 없어요")
                    Tendency(personality: "관계 목적", value: "언어 공부", isLineHidden: true)
                    Section(title: "한 줄 소개", isMore: true)
                    OneLiner(introduceText: "안녕하세요. 김밋키입니다! 새로운 친구를 사귀고 싶습니다. MBTI는 ENTP입니다.")
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 18)
            }
            .background(.white01)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top, 27)
            .padding(.horizontal, 20)
            
        }
        .background(.background1)
        .ignoresSafeArea()
    }
}

#Preview {
    MyProfile()
}
