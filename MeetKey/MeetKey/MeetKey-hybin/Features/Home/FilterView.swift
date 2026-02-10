import SwiftUI


protocol DisplayableFilter: Identifiable {
    var displayName: String { get }
}

// 기존 Enum들에 프로토콜 채택 (이미 displayName이 있으니 선언만 하면 됨)
extension socialType: DisplayableFilter {}
extension meetingType: DisplayableFilter {}
extension chatType: DisplayableFilter {}


struct FilterView: View {
    @ObservedObject var homeVM: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    // 임시로 들고 있을 필터 (저장 버튼 누를 때만 적용하고 싶을 경우 대비)
    @State private var tempFilter: FilterModel
    
    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
        self._tempFilter = State(initialValue: homeVM.filter)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    interestFilterSection
                    
                    personalityFilterSection
                    
                    nationalitySection
                    
                    nativeLanguageSection
                    
                    targetLanguageSection
                    
                    languageLevelSection
                    
                    AgeFilterSection(minAge: $tempFilter.minAge, maxAge: $tempFilter.maxAge)
                    
                    DistanceFilterSection(maxDistance: $tempFilter.maxDistance)
                }
                .padding(.top, 13)
            }
            
            // 적용 버튼
            applyButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Subviews (디자인 베끼기)
    
    private var headerView: some View {
        HStack(spacing: 0) {
            Image(.arrowLeft2)
                .frame(width: 24, height: 24)
                .onTapGesture { dismiss() }
            Spacer()
            Text("필터")
                .font(.meetKey(.title2))
            Spacer()
            Image(.arrowLeft2).frame(width: 24, height: 24).hidden()
        }
        .frame(height: 36)
        .padding(.top, 42)
        .padding(.bottom, 20)
    }

    private var personalityFilterSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            filterGroup(title: "소셜 성향", items: socialType.allCases, selected: tempFilter.social) { tempFilter.social = $0 }
            filterGroup(title: "대화 인원", items: meetingType.allCases, selected: tempFilter.meeting) { tempFilter.meeting = $0 }
            filterGroup(title: "대화 주도", items: chatType.allCases, selected: tempFilter.chat) { tempFilter.chat = $0 }
        }
    }

    // 공통 필터 그룹 UI (TagFlowLayout 활용)
    private func filterGroup<T: DisplayableFilter & Equatable>(
        title: String,
        items: [T],
        selected: T?,
        onTap: @escaping (T) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.meetKey(.body4))
                .foregroundColor(.text3)
            
            TagFlowLayout(spacing: 8) {
                ForEach(items) { item in
                    InterestTagButton(
                        text: item.displayName,
                        isSelected: selected == item
                    ) {
                        onTap(item)
                    }
                }
            }
        }
    }

    private var interestFilterSection: some View {
        VStack(alignment: .leading, spacing: 32) {
            // 이제 group은 InterestGroup 타입이므로 id를 따로 명시 안 해도 됩니다 (Identifiable 준수 시)
            ForEach(homeVM.groupedInterests) { group in
                VStack(alignment: .leading, spacing: 12) {
                    Text(group.category) // 이제 에러 없이 접근 가능
                        .font(.meetKey(.body4))
                        .foregroundColor(.text3)
                    
                    TagFlowLayout(spacing: 8) {
                        ForEach(group.items) { item in
                            InterestTagButton(
                                text: item.displayName,
                                isSelected: tempFilter.interests?.contains(item.displayName) ?? false
                            ) {
                                toggleInterest(item.displayName)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var nationalitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("국적")
                .font(.meetKey(.body4))
                .foregroundColor(.text3)
            
            TagFlowLayout(spacing: 8) {
                ForEach(NationalityType.allCases) { nation in
                    InterestTagButton(
                        // text: "\(nation.flag) \(nation.displayName)", // 국기 포함 시
                        text: nation.displayName,
                        isSelected: tempFilter.hometown == nation.displayName
                    ) {
                        // 단일 선택 로직
                        if tempFilter.hometown == nation.displayName {
                            tempFilter.hometown = nil
                        } else {
                            tempFilter.hometown = nation.displayName
                        }
                    }
                }
            }
        }
    }
    
    // 1. 모국어 섹션
    private var nativeLanguageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("사용 언어 (모국어)")
                .font(.meetKey(.body4))
                .foregroundColor(.text3)
            
            TagFlowLayout(spacing: 8) {
                ForEach(LanguageType.allCases) { language in
                    InterestTagButton(
                        text: language.displayName,
                        isSelected: tempFilter.nativeLanguage == language.displayName
                    ) {
                        tempFilter.nativeLanguage = (tempFilter.nativeLanguage == language.displayName) ? nil : language.displayName
                    }
                }
            }
        }
    }

    // 2. 관심 언어 섹션
    private var targetLanguageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("관심 언어 (학습 중)")
                .font(.meetKey(.body4))
                .foregroundColor(.text3)
            
            TagFlowLayout(spacing: 8) {
                ForEach(LanguageType.allCases) { language in
                    InterestTagButton(
                        text: language.displayName,
                        isSelected: tempFilter.targetLanguage == language.displayName
                    ) {
                        tempFilter.targetLanguage = (tempFilter.targetLanguage == language.displayName) ? nil : language.displayName
                    }
                }
            }
        }
    }
    
    private var languageLevelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("언어 실력")
                .font(.meetKey(.body4))
                .foregroundColor(.text3)
            
            TagFlowLayout(spacing: 8) {
                ForEach(LanguageLevelType.allCases) { level in
                    InterestTagButton(
                        text: level.displayName,
                        isSelected: tempFilter.targetLanguageLevel == level.rawValue // 서버 규격이 대문자일 테니 rawValue 비교
                    ) {
                        // 단일 선택 로직
                        if tempFilter.targetLanguageLevel == level.rawValue {
                            tempFilter.targetLanguageLevel = nil
                        } else {
                            tempFilter.targetLanguageLevel = level.rawValue
                        }
                    }
                }
            }
        }
    }
    

    private var applyButton: some View {
        Button {
            homeVM.filter = tempFilter // 변경사항 반영
            dismiss()
        } label: {
            Text("필터 적용하기")
                .font(.meetKey(.title5))
                .foregroundColor(.white01)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.main)
                .cornerRadius(15)
        }
        .padding(.bottom, 20)
    }
    
    private func toggleInterest(_ name: String) {
        if var list = tempFilter.interests {
            if list.contains(name) { list.removeAll { $0 == name } }
            else { list.append(name) }
            tempFilter.interests = list
        } else {
            tempFilter.interests = [name]
        }
    }
}

