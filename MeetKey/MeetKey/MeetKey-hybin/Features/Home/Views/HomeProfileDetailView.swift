import SwiftUI

struct HomeProfileDetailView: View {
    @ObservedObject var homeVM: HomeViewModel
    let size: CGSize
    let safeArea: EdgeInsets
    
    var body: some View {
        // 1. 현재 선택된 유저가 있을 때만 렌더링
        if let user = homeVM.currentUser {
            ZStack(alignment: .bottomLeading){
                VStack(spacing:15){
                    // --- 상단 메인 이미지 섹션 ---
                    mainProfileImage(user: user)
                        .zIndex(1)
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading , spacing: 15) {

                            // --- 언어 섹션 (사용 언어, 관심 언어) ---
                            languageSection(user: user)
                            
                            // --- 관심사 섹션 (칩 레이아웃) ---
                            interestSection(user: user)
                            
                            // --- 성향 섹션 (리스트) ---
                            personalitySection(user: user)
                            
                            // --- 한 줄 소개 섹션 ---
                            bioSection(bio: user.bio ?? "소개글이 없습니다.")
                        }
                        .padding(.top, 15)
                        .padding(.bottom, 25)
                        .padding(.horizontal , 20)

                    }
                }
                .background(Color.white01)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 20)
                .padding(.top, safeArea.top + 15)
                .padding(.bottom, safeArea.bottom + 20)
            }
        }
    }
}

// MARK: - [Private Components] UI 부품들
private extension HomeProfileDetailView {
    
    // 1. 메인 프로필 이미지 & 뱃지
    private func mainProfileImage(user: User) -> some View {
        ZStack (alignment:.bottom) {
            Image(user.profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width - 40, height: 330)
                .overlay(alignment: .topTrailing) {
                    // 팀원 뱃지 로직 통합 연동
                    if let badgeData = user.badge {
                        homeBadgeView(score: badgeData.totalScore)
                    }
                }
            userInfoSection(user: user)
        }
    }
    
    // 2. 유저 기본 정보
    private func userInfoSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                // ageInt 계산 프로퍼티 활용
                Text("\(user.name)")
                    .font(.meetKey(.title2))
                    .foregroundStyle(Color.white01)
                Text("\(user.ageInt)")
                    .font(.meetKey(.title6))
                    .foregroundStyle(Color.white01)
                Spacer()
            }
            Label("\(user.location ?? "Unknown"), \(user.distance ?? "??")근처", systemImage: "location.fill")
                .font(.meetKey(.body5))
                .foregroundStyle(Color.white01.opacity(0.8)) ///#EEEEEE - Color.gray인데 잘 안보여서,,
            ///Label 출신국가 넣어야함
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
    }
    
    // 3. 언어 섹션
    private func languageSection(user: User) -> some View {
        HStack(alignment: .top , spacing: 0) {
            languageCard(title: "사용 언어", language: user.first ?? "Unknown", flag: "🌐", level: nil)
            
            //중앙 구분선
            Rectangle()
                .fill(Color.black04)
                .frame(width:1)
                .padding(.vertical, 16)
            
            languageCard(title: "관심 언어", language: user.target ?? "Unknown", flag: "🌐", level: user.level)
        }
        .background(Color.background1)
        .clipShape(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
        )
    }

    // 4. 관심사 섹션 (동적 칩 생성)
    private func interestSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("관심사").font(.meetKey(.body2))
            
            if let interests = user.interests, !interests.isEmpty {
                // 칩들을 줄 단위로 쪼개주는 함수 호출
                let rows = generateRows(interests: interests, screenWidth: size.width - 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(row, id: \.self) { item in
                                interestChip(item)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 5. 내 성향 섹션
    private func personalitySection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("내 성향")
                .font(.meetKey(.body1))
                .foregroundStyle(Color.text1)
            
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

    }

    // 6. 한 줄 소개
    private func bioSection(bio: String) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("한 줄 소개")
                .font(.meetKey(.body1))
                .foregroundStyle(.text1)
            Text(bio)
                .font(.meetKey(.body5))
                .foregroundStyle(Color.text3)
                .lineSpacing(6)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.background1)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

// MARK: - [Helper Views] 반복되는 작은 디자인 컴포넌트들
private extension HomeProfileDetailView {
    
    private func interestChip(_ text: String) -> some View {
        Text(text)
            .font(.meetKey(.body2))
            .foregroundStyle(Color.main)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .background(Color.bubble31, in: Capsule())
            .overlay(alignment: .center) {
                Capsule()
                    .stroke(.main, lineWidth: 1)
            }
    }
    
    private func languageCard(title: String, language: String, flag: String, level: String?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.meetKey(.body5)).foregroundStyle(Color.text3)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(language).font(.meetKey(.title5))
                    Text(flag) //이미지로 바꿔야함
                }
                
                if let level = level {
                    Text(level)
                        .font(.meetKey(.body4))
                        .foregroundStyle(Color.main)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.sub1)
                        .clipShape(RoundedRectangle(cornerRadius:15))
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func personalityRow(title: String, value: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .foregroundStyle(Color.text3)
                    .font(.meetKey(.body5))
                Spacer()
                Text(value)
                    .font(.meetKey(.body4))
                    .foregroundStyle(Color.text2)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            Divider().padding(.horizontal, 15)
        }
    }
}

//MARK: - 홈뷰 전용 뱃지 디자인
private extension HomeProfileDetailView {
    @ViewBuilder
    private func homeBadgeView(score: Int) -> some View{
        let type = BadgeType1.from(score:score)
        
        let tagName = type.assetName.replacingOccurrences(of: "Badge", with: "Tag")
        
        HStack{
            Image(tagName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:60 , height:25)
        }
        .padding()
    }
}

//MARK: - LazyVGrid 대신 사용할 로직 함수,,,
private extension HomeProfileDetailView {
    private func generateRows(interests: [String], screenWidth: CGFloat) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        
        var totalWidth: CGFloat = 0
        
        for interest in interests {
            // 단어의 대략적인 너비 계산 (폰트 크기 + 패딩)
            let font = UIFont(name:"Pretendard-Medium", size: 16) // .body2에 맞게 조절
            let attributes = [NSAttributedString.Key.font: font]
            let size = (interest as NSString).size(withAttributes: attributes as [NSAttributedString.Key : Any])
            let chipWidth = size.width + 24 + 8 // (글자너비 + 가로패딩 + 칩간격)
            
            if totalWidth + chipWidth > screenWidth {
                rows.append(currentRow)
                currentRow = [interest]
                totalWidth = chipWidth
            } else {
                currentRow.append(interest)
                totalWidth += chipWidth
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
}
