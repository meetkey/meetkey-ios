//
//  OtherProfile.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct OtherProfile: View {
    let interests = [
        "여행", "수영", "헬스", "외국어",
        "맛집", "영화", "반려동물", "음악",
        "여행", "수영", "헬스", "외국어"
    ]
    var name: String = "홍길동"
    var age: Int = 30
    var location: String = "서울시 마포구, 20Km 근처"
    var nation: String = "미국"
    var sex: String = "남성"
    var safeTag: Image = Image(.bronzeTag)

    @Binding var user: User
    
    var body: some View {
        ZStack {
            Image(.otherProfileBack)
                .resizable()
            ScrollView {
                Image(.SAFE)//네비바 임시대체뷰
                    .frame(height: 132)
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
                        Image(.otherProfile)
                            .resizable()
                            .frame(width: .infinity, height: 350)
                        safeTag
                            .padding(.bottom, 304)
                            .padding(.leading, 282)
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                                Text(name)
                                    .font(.meetKey(.title2))
                                    .foregroundStyle(.white01)
                                Text("\(age)")
                                    .font(.meetKey(.title6))
                                    .foregroundStyle(.white01)
                                    .padding(.leading, 4)
                            }
                            HStack {
                                Image(.location)
                                Text(location)
                                    .font(.meetKey(.body5))
                                    .foregroundStyle(.background2)
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 2)
                            HStack {
                                Image(.moreCircle)
                                Text("출신국가 : \(nation) / 성별 : \(sex)")
                                    .font(.meetKey(.body5))
                                    .foregroundStyle(.background2)
                            }
                        }
                        .padding(.leading, 19)
                        .padding(.bottom, 24)
                        
                        
                    }
                    VStack(spacing: 18) {
                        Recommend(recommend: 165, notRecommend: 12)
                        Section(title: "SAFE 뱃지 점수", isMore: false)
                            .padding(.top, 5)
                        Badge(score: 90)
                        Section(title: "사용 언어", isMore: false)
                        Language(usingLanguage: $user.first, interestingLanguage: $user.target, )
                        Section(title: "관심사", isMore: false)
                        
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
                        Section(title: "내 성향", isMore: false)
                        Tendency(personality: "성격", value: "외향적")
                        Tendency(personality: "선호하는 만남 방식", value: "상관 없어요")
                        Tendency(personality: "대화 스타일", value: "먼저 말 걸어 주세요")
                        Tendency(personality: "친구 유형", value: "상관 없어요")
                        Tendency(personality: "관계 목적", value: "언어 공부", isLineHidden: true)
                        Section(title: "한 줄 소개", isMore: false)
                        OneLiner(introduceText: "안녕하세요. 김밋키입니다! 새로운 친구를 사귀고 싶습니다. MBTI는 ENTP입니다.")
                            .padding(.bottom, 7)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    
                }
                .background(.white01)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.top, 38)
                .padding(.horizontal, 20)
                
                
            }
            
        }
        .ignoresSafeArea()
        
    }
}
