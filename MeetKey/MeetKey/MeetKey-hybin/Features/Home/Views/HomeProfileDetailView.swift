import SwiftUI

struct HomeProfileDetailView: View {
    @ObservedObject var homeVM: HomeViewModel
    let size: CGSize
    let safeArea: EdgeInsets
    
    var body: some View {
        // 1. 현재 선택된 유저가 있을 때만 렌더링
        if let user = homeVM.currentUser {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // --- 상단 메인 이미지 섹션 ---
                        mainProfileImage(user: user)
                        
                        // --- 기본 정보 섹션 (이름, 나이, 위치) ---
                        userInfoSection(user: user)
                        
                        // --- 언어 섹션 (사용 언어, 관심 언어) ---
                        languageSection(user: user)
                        
                        // --- 관심사 섹션 (칩 레이아웃) ---
                        interestSection(user: user)
                        
                        // --- 성향 섹션 (리스트) ---
                        personalitySection(user: user)
                        
                        // --- 한 줄 소개 섹션 ---
                        bioSection(bio: user.bio ?? "소개글이 없습니다.")
                    }
                    .padding(.bottom, 20)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 20)
                .padding(.top, safeArea.top + 55)
                .padding(.bottom, safeArea.bottom + 20)
            }
        }
    }
}

// MARK: - [Private Components] UI 부품들
private extension HomeProfileDetailView {
    
    // 1. 메인 프로필 이미지 & 뱃지
    private func mainProfileImage(user: User) -> some View {
        Image(user.profileImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width - 40, height: 420)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay(alignment: .topTrailing) {
                // 팀원 뱃지 로직 통합 연동
                if let badgeData = user.badge {
                    Badge(score: badgeData.totalScore)
                        .frame(width: 80, height: 40)
                        .padding(15)
                }
            }
    }
    
    // 2. 유저 기본 정보
    private func userInfoSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                // ageInt 계산 프로퍼티 활용
                Text("\(user.name) \(user.ageInt)")
                    .font(.system(size: 28, weight: .bold))
                Spacer()
            }
            Label("\(user.location ?? "Unknown"), \(user.distance ?? "??")km 근처", systemImage: "location.fill")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
    }
    
    // 3. 언어 섹션
    private var languageSection: some View { // body에서 호출 시 가독성을 위해 func로 변경 권장
        // 하단 languageSection(user:) 참고
        EmptyView()
    }
    
    private func languageSection(user: User) -> some View {
        HStack(spacing: 12) {
            languageCard(title: "사용 언어", language: user.first ?? "Unknown", flag: "🌐", level: nil)
            languageCard(title: "관심 언어", language: user.target ?? "Unknown", flag: "🌐", level: user.level)
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }

    // 4. 관심사 섹션 (동적 칩 생성)
    private func interestSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("관심사").font(.system(size: 18, weight: .bold))
            
            if let interests = user.interests, !interests.isEmpty {
                // Flexible한 배치를 위해 LazyVGrid 도입 (하드코딩 탈출!)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], alignment: .leading, spacing: 10) {
                    ForEach(interests, id: \.self) { item in
                        interestChip(item)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    // 5. 내 성향 섹션
    private func personalitySection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("내 성향").font(.system(size: 18, weight: .bold))
            
            if let p = user.personalities {
                VStack(spacing: 0) {
                    personalityRow(title: "성격", value: p.socialType)
                    personalityRow(title: "선호 만남", value: p.meetingType)
                    personalityRow(title: "대화 스타일", value: p.chatType)
                    personalityRow(title: "친구 유형", value: p.friendType)
                    personalityRow(title: "선호 관계", value: p.relationType)
                }
                .background(Color.gray.opacity(0.05))
                .cornerRadius(15)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }

    // 6. 한 줄 소개
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

// MARK: - [Helper Views] 반복되는 작은 디자인 컴포넌트들
private extension HomeProfileDetailView {
    
    private func interestChip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().stroke(Color.orange, lineWidth: 1))
            .foregroundColor(.orange)
    }
    
    private func languageCard(title: String, language: String, flag: String, level: String?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 14)).foregroundColor(.gray)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(language).font(.system(size: 18, weight: .bold))
                    Text(flag)
                }
                if let level = level {
                    Text(level)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1)).cornerRadius(5)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
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
}
