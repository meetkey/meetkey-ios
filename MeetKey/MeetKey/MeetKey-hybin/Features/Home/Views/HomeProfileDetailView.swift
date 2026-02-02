import SwiftUI

struct HomeProfileDetailView: View {
    @ObservedObject var homeVM: HomeViewModel
    let size: CGSize
    let safeArea: EdgeInsets
    
    var body: some View {
        if let user = homeVM.currentUser {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // 1. 메인 이미지 (상단 꽉 채우기)
                        Image(user.profileImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width - 40, height: 420)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .overlay(safeBadge, alignment: .topTrailing) // 세이프 배지
                        
                        // 2. 유저 기본 정보 (이름, 위치)
                        userInfoSection(user: user)
                        
                        // 3. 언어 섹션
                        languageSection
                        
                        // 4. 관심사 섹션 (칩 레이아웃)
                        interestSection
                        
                        // 5. 내 성향 섹션 (리스트)
                        personalitySection
                        
                        // 6. 한 줄 소개 섹션
                        bioSection(bio: user.bio)
                    }
                    .padding(.bottom, 20)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 20)
                .padding(.top, safeArea.top + 55) // 헤더와 겹치지 않게 조절
                .padding(.bottom, safeArea.bottom + 20)
            }
        }
    }
}

// MARK: - 하드코딩된 목데이터 및 서브뷰
extension HomeProfileDetailView {
    
    // 1. 세이프 배지
    private var safeBadge: some View {
        Text("✓ SAFE")
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.yellow.opacity(0.8))
            .cornerRadius(10)
            .padding(15)
    }
    
    // 2. 유저 기본 정보
    private func userInfoSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                Text("\(user.name) \(user.age)") // 나이 데이터 없으면 24
                    .font(.system(size: 28, weight: .bold))
                Spacer()
            }
            Label("서울시 마포구, 20km 근처", systemImage: "location.fill")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
    }

    // 3. 관심사 (목데이터 적용)
    private var interestSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("관심사").font(.system(size: 18, weight: .bold))
            
            // 피그마 디자인처럼 칩 형태로 나열
            let interests = ["K-POP", "여행", "음식", "영화", "운동", "맛집 찾기", "일상 브이로그"]
            
            // 주말 마감용: 일단 HStack 두 줄로 하드코딩 ㅋㅋㅋ
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ForEach(interests.prefix(4), id: \.self) { item in
                        interestChip(item)
                    }
                }
                HStack {
                    ForEach(interests.dropFirst(4), id: \.self) { item in
                        interestChip(item)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    private func interestChip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().stroke(Color.orange, lineWidth: 1))
            .foregroundColor(.orange)
    }

    // 4. 내 성향 (목데이터 적용)
    private var personalitySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("내 성향").font(.system(size: 18, weight: .bold))
            
            VStack(spacing: 0) {
                personalityRow(title: "성격", value: "외향적")
                personalityRow(title: "선호하는 만남 방식", value: "상관 없어요")
                personalityRow(title: "대화 스타일", value: "먼저 말 걸어 주세요")
                personalityRow(title: "친구 유형", value: "상관 없어요")
            }
            .background(Color.gray.opacity(0.05))
            .cornerRadius(15)
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    private func personalityRow(title: String, value: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title).foregroundColor(.gray)
                Spacer()
                Text(value).fontWeight(.medium)
            }
            .font(.system(size: 14))
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            
            Divider().padding(.horizontal, 15)
        }
    }
    
    // 5. 한 줄 소개
    private func bioSection(bio: String) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("한 줄 소개").font(.system(size: 18, weight: .bold))
            
            Text(bio)
                .font(.system(size: 15))
                .lineSpacing(6)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
}

extension HomeProfileDetailView {
    
    private var languageSection: some View {
        HStack(spacing: 12) {
            // 1. 사용 언어 카드
            languageCard(title: "사용 언어", language: "English", flag: "🇺🇸", level: nil)
            
            // 2. 관심 언어 카드
            languageCard(title: "관심 언어", language: "Korean", flag: "🇰🇷", level: "초보")
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    private func languageCard(title: String, language: String, flag: String, level: String?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(language)
                        .font(.system(size: 18, weight: .bold))
                    Text(flag) // 국기 이모지
                }
                
                // 숙련도 배지가 있을 때만 표시 (예: '초보')
                if let level = level {
                    Text(level)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(5)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
    }
}
