import SwiftUI
import Combine
import Alamofire

// Data 모델
struct OnboardingData {
    var hometown: String?
    var nativeLanguage: String?
    var targetLanguage: String?
    var proficiency: String?
    
    // Basic 기본 정보
    var name: String = ""
    var birthDateString: String = ""
    var gender: String?
    
    // Photo 사진
    var profileImageURLs: [String] = []
    
    // Interest 관심사 중복 방지 Set
    var interests: Set<String> = []
    
    // Personality 성향 Key 질문 Value 답변
    var personality: [String: String] = [:]
}

class OnboardingViewModel: ObservableObject {
    @Published var data = OnboardingData()
    @Published var personalityCategories: [PersonalityCategory] = []
    @Published var interestCategories: [InterestCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOnboardingCompleted: Bool = false

    private let userService = UserService.shared
    private let authService = AuthService.shared
    private let isNewMemberKey = "isNewMember"
    private let authProviderKey = "authProvider"
    private let lastIdTokenKey = "lastIdToken"
    private let phoneNumberKey = "phoneNumber"

    init() {
        fetchOptions()
    }
    @Published var path = NavigationPath()
    
    @Published var targetLanguageLevel: Double = 1.0
    
    @Published var isDatePickerPresented: Bool = false
    @Published var birthday: Date? = nil {
        didSet {
            if let date = birthday {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                data.birthDateString = formatter.string(from: date)
            }
        }
    }
    
    // Photo 사진 관련
    @Published var profileImages: [Int: UIImage] = [:]
    @Published var showImageActionSheet: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @Published var selectedImageIndex: Int? = nil
    
    private let fallbackInterestCategories: [InterestCategory] = [
        InterestCategory(
            category: "일상 · 라이프스타일",
            items: [
                InterestItem(code: "TRAVEL", name: "여행"),
                InterestItem(code: "CAFE", name: "카페 탐방"),
                InterestItem(code: "RESTAURANT", name: "맛집 찾기"),
                InterestItem(code: "WALK", name: "산책"),
                InterestItem(code: "PET", name: "반려동물"),
                InterestItem(code: "VLOG", name: "일상 브이로그"),
                InterestItem(code: "PHOTO", name: "사진찍기"),
                InterestItem(code: "KNIT", name: "뜨개질"),
                InterestItem(code: "LIFE", name: "미니멀 라이프"),
                InterestItem(code: "DEVELOP", name: "자기계발")
            ]
        ),
        InterestCategory(
            category: "문화 · 콘텐츠",
            items: [
                InterestItem(code: "MOVIE", name: "영화"),
                InterestItem(code: "DRAMA", name: "드라마"),
                InterestItem(code: "MUSIC", name: "음악"),
                InterestItem(code: "KPOP", name: "K-POP"),
                InterestItem(code: "POP", name: "해외 팝송"),
                InterestItem(code: "NETFLIX", name: "넷플릭스"),
                InterestItem(code: "YOUTUBE", name: "유튜브"),
                InterestItem(code: "WEBTOON", name: "웹툰/만화"),
                InterestItem(code: "ANIMATION", name: "애니메이션"),
                InterestItem(code: "GAME", name: "게임"),
                InterestItem(code: "BOOK", name: "책")
            ]
        ),
        InterestCategory(
            category: "지식 · 시사",
            items: [
                InterestItem(code: "LANGUAGE", name: "언어 공부"),
                InterestItem(code: "STOCK", name: "주식"),
                InterestItem(code: "INVESTMENT", name: "투자"),
                InterestItem(code: "NEWS", name: "뉴스"),
                InterestItem(code: "SOCIALISSUES", name: "사회 이슈"),
                InterestItem(code: "TECH", name: "테크/IT"),
                InterestItem(code: "BUSINESS", name: "비즈니스"),
                InterestItem(code: "DESIGN", name: "디자인"),
                InterestItem(code: "MARKETING", name: "마케팅"),
                InterestItem(code: "JOB", name: "취업"),
                InterestItem(code: "CAREER", name: "커리어")
            ]
        )
    ]
    
    var interestGroups: [InterestCategory] {
        interestCategories.isEmpty ? fallbackInterestCategories : interestCategories
    }

    func toggleInterest(_ code: String) {
        if data.interests.contains(code) {
            data.interests.remove(code)
        } else {
            data.interests.insert(code)
        }
    }
    
    private let fallbackPersonalityCategories: [PersonalityCategory] = [
        PersonalityCategory(title: "사회적 에너지 성향", options: ["EXTROVERT", "INTROVERT", "OCCASIONAL"]),
        PersonalityCategory(title: "선호하는 만남 방식", options: ["GROUP", "ONE", "ANY"]),
        PersonalityCategory(title: "대화 시작 스타일", options: ["INITIATOR", "RESPONDER", "BALANCED"]),
        PersonalityCategory(title: "친구 유형 선호도", options: ["SAME_GENDER", "OPPOSITE_GENDER", "ANY"]),
        PersonalityCategory(title: "관계 목적", options: ["CASUAL", "LEARNING", "CULTURE_EXCHANGE", "FRIENDSHIP", "OFFLINE_MEETUP", "TRAVEL_GUIDE"])
    ]

    var personalityQuestions: [(question: String, options: [String])] {
        let categories = personalityCategories.isEmpty ? fallbackPersonalityCategories : personalityCategories
        return categories.map { category in
            let labelMap = personalityOptionLabelMap(for: category.title)
            let labels = category.options.map { labelMap[$0] ?? $0 }
            return (question: category.title, options: labels)
        }
    }
    
    // Personality 선택 로직 질문당 하나만 선택
    func selectPersonality(question: String, option: String) {
        let codeMap = personalityOptionCodeMap(for: question)
        data.personality[question] = codeMap[option] ?? option
    }

    func isPersonalitySelected(question: String, optionLabel: String) -> Bool {
        let codeMap = personalityOptionCodeMap(for: question)
        let code = codeMap[optionLabel] ?? optionLabel
        return data.personality[question] == code
    }
    
    // Validation 검증 로직들
    // Step 1 기본 정보 완료 여부
    var isBasicInfoCompleted: Bool {
        return data.hometown != nil && data.nativeLanguage != nil && data.targetLanguage != nil
    }
    
    // Step 2 프로필 정보 완료 여부 이름 생일 성별
    var isProfileInfoCompleted: Bool {
        return !data.name.isEmpty && !data.birthDateString.isEmpty && data.gender != nil
    }
    
    // Step 3 사진 등록 완료 여부 3장 필수
    var isProfileImagesCompleted: Bool {
        return profileImages.count == 3
    }
    
    // Step 4 관심사 선택 완료 여부 전체 3개 이상
    var isInterestSelectionCompleted: Bool {
        return data.interests.count >= 3
    }
    
    // Step 5 성향 선택 완료 여부 모든 질문 답변
    var isPersonalitySelectionCompleted: Bool {
        return data.personality.count == personalityQuestions.count
    }
    
    // Helper 기타 헬퍼
    var birthdayDisplayString: String {
        guard let date = birthday else { return "YYYY/MM/DD" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    let countries = ["USA", "UK", "China", "Japan", "Korea", "France", "Germany", "Italy", "Spain"]
    let languages = ["영어 (English)", "한국어 (한국어)", "중국어 (中國語)", "일본어 (日本語)", "스페인어 (Español)", "프랑스어 (Français)", "독일어 (Deutsch)", "이탈리아어 (Italiano)", "러시아어 (Pусский)"]
    private let languageCodeMap: [String: AppLanguage] = [
        "영어 (English)": .english,
        "한국어 (한국어)": .korean,
        "중국어 (中國語)": .chinese,
        "일본어 (日本語)": .japanese,
        "스페인어 (Español)": .spanish,
        "프랑스어 (Français)": .french,
        "독일어 (Deutsch)": .german,
        "이탈리아어 (Italiano)": .italian,
        "러시아어 (Pусский)": .russian
    ]

    func fetchOptions() {
        isLoading = true
        errorMessage = nil
        print("📡 [온보딩] 옵션 데이터 요청 시작")

        Task { @MainActor in
            do {
                async let personality = userService.fetchPersonalityOptions()
                async let interest = userService.fetchInterestOptions()
                let (personalityData, interestData) = try await (personality, interest)
                self.personalityCategories = personalityData.categories
                self.interestCategories = interestData.categories
                print("✅ [온보딩] 옵션 데이터 수신 성공! (관심사 개수: \(interestData.categories.count), 성향 개수: \(personalityData.categories.count))")
            } catch {
                self.errorMessage = error.localizedDescription
                print("❌ [온보딩] 옵션 데이터 요청 실패: \(error)")
            }
            self.isLoading = false
        }
    }

    func saveOnboardingData() {
        isLoading = true
        errorMessage = nil
        print("💾 [온보딩] 사용자 데이터 저장 시작 (선택한 관심사: \(Array(data.interests)))")

        Task { @MainActor in
            do {
                if isNewMemberFlow() {
                    let signupRequest = try buildSignupRequest()
                    let provider = try loadAuthProvider()
                    let signupResponse = try await authService.signup(provider: provider, request: signupRequest)

                    if let accessToken = signupResponse.accessToken,
                       let refreshToken = signupResponse.refreshToken {
                        try KeychainManager.save(value: accessToken, account: "accessToken")
                        try KeychainManager.save(value: refreshToken, account: "refreshToken")
                    } else {
                        let idToken = try loadLastIdToken()
                        let loginResponse = try await authService.login(provider: provider, idToken: idToken)
                        guard let accessToken = loginResponse.accessToken,
                              let refreshToken = loginResponse.refreshToken else {
                            throw OnboardingError.missingSignupToken
                        }
                        try KeychainManager.save(value: accessToken, account: "accessToken")
                        try KeychainManager.save(value: refreshToken, account: "refreshToken")
                    }
                }

                if !profileImages.isEmpty {
                    let uploadItems = buildPhotoUploadItems()
                    let presigned = try await userService.requestPhotoUpload(uploadItems)
                    try await uploadPhotos(presigned, items: uploadItems)
                    try await userService.registerPhotos(keys: presigned.map { $0.key })
                }

                let interestsRequest = InterestsUpdateRequest(interests: Array(data.interests))
                _ = try await userService.updateInterests(interestsRequest)

                let personalityRequest = try buildPersonalityRequest()
                _ = try await userService.updatePersonality(personalityRequest)

                self.isOnboardingCompleted = true
                print("🎉 [온보딩] 모든 데이터 저장 완료! 메인으로 이동합니다.")
            } catch {
                self.errorMessage = error.localizedDescription
                print("⚠️ [온보딩] 저장 실패: \(error)")
            }
            self.isLoading = false
        }
    }

    private func isNewMemberFlow() -> Bool {
        if let value = UserDefaults.standard.object(forKey: isNewMemberKey) as? Bool {
            return value
        }
        return false
    }

    private func loadAuthProvider() throws -> SocialProvider {
        guard let raw = UserDefaults.standard.string(forKey: authProviderKey),
              let provider = SocialProvider(rawValue: raw) else {
            throw OnboardingError.missingLoginContext
        }
        return provider
    }

    private func loadLastIdToken() throws -> String {
        guard let token = UserDefaults.standard.string(forKey: lastIdTokenKey),
              !token.isEmpty else {
            throw OnboardingError.missingLoginContext
        }
        return token
    }

    private func buildSignupRequest() throws -> SignupRequest {
        guard let idToken = UserDefaults.standard.string(forKey: lastIdTokenKey) else {
            throw OnboardingError.missingLoginContext
        }

        let birthday = formatBirthday()
        let gender = mapGender(data.gender)
        let homeTown = mapCountry(data.hometown)
        let firstLanguage = mapLanguage(data.nativeLanguage)
        let targetLanguage = mapLanguage(data.targetLanguage)
        let targetLevel = mapLanguageLevel()
        let phoneNumber = "+821000000000"

        return SignupRequest(
            idToken: idToken,
            name: data.name,
            birthday: birthday,
            gender: gender,
            homeTown: homeTown,
            firstLanguage: firstLanguage,
            targetLanguage: targetLanguage,
            targetLanguageLevel: targetLevel,
            phoneNumber: phoneNumber
        )
    }

    private func formatBirthday() -> String {
        if let birthday = birthday {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: birthday)
        }
        if data.birthDateString.count == 8 {
            let year = data.birthDateString.prefix(4)
            let month = data.birthDateString.dropFirst(4).prefix(2)
            let day = data.birthDateString.suffix(2)
            return "\(year)-\(month)-\(day)"
        }
        return data.birthDateString
    }

    private func mapGender(_ value: String?) -> Gender {
        switch value {
        case "남자", "MALE":
            return .male
        case "여자", "FEMALE":
            return .female
        default:
            return .male
        }
    }

    private func mapLanguage(_ value: String?) -> AppLanguage {
        guard let value else { return .english }
        if let mapped = languageCodeMap[value] { return mapped }
        if let byCode = AppLanguage(rawValue: value.uppercased()) { return byCode }
        if value.contains("한국") { return .korean }
        if value.contains("일본") { return .japanese }
        if value.contains("중국") { return .chinese }
        if value.contains("스페인") { return .spanish }
        if value.contains("프랑스") { return .french }
        if value.contains("독일") { return .german }
        if value.contains("이탈리아") { return .italian }
        if value.contains("러시아") { return .russian }
        return .english
    }

    private func mapLanguageLevel() -> LanguageLevel {
        switch targetLanguageLevel {
        case 1.0: return .novice
        case 2.0: return .beginner
        case 3.0: return .intermediate
        case 4.0: return .advanced
        default: return .fluent
        }
    }
    
    private func mapCountry(_ value: String?) -> String {
        guard let value else { return "" }
        return value.uppercased()
    }

    private func buildPhotoUploadItems() -> [PhotoUploadRequestItem] {
        let sorted = profileImages.sorted { $0.key < $1.key }
        return sorted.map { (index, _) in
            PhotoUploadRequestItem(
                fileName: "profile_\(index).jpg",
                contentType: "image/jpeg"
            )
        }
    }

    private func uploadPhotos(_ presigned: [PhotoUploadResponseItem], items: [PhotoUploadRequestItem]) async throws {
        for (index, presignedItem) in presigned.enumerated() {
            guard let image = profileImages.sorted(by: { $0.key < $1.key })[safe: index]?.value,
                  let data = image.jpegData(compressionQuality: 0.8) else {
                continue
            }
            try await uploadImageToS3(urlString: presignedItem.url, data: data, contentType: items[index].contentType)
        }
    }

    private func uploadImageToS3(urlString: String, data: Data, contentType: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            AF.upload(
                data,
                to: urlString,
                method: .put,
                headers: ["Content-Type": contentType]
            )
            .validate(statusCode: 200..<300)
            .response { response in
                if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func buildPersonalityRequest() throws -> PersonalityUpdateRequest {
        let map = personalityTitleMap()
        var socialType: String?
        var meetingType: String?
        var chatType: String?
        var friendType: String?
        var relationType: String?

        for (title, option) in data.personality {
            switch map[title] {
            case .socialType:
                socialType = option
            case .meetingType:
                meetingType = option
            case .chatType:
                chatType = option
            case .friendType:
                friendType = option
            case .relationType:
                relationType = option
            case .none:
                break
            }
        }

        guard let socialType,
              let meetingType,
              let chatType,
              let friendType,
              let relationType else {
            throw OnboardingError.invalidPersonalitySelection
        }

        return PersonalityUpdateRequest(
            socialType: socialType,
            meetingType: meetingType,
            chatType: chatType,
            friendType: friendType,
            relationType: relationType
        )
    }

    private func personalityTitleMap() -> [String: PersonalityField] {
        return [
            "사회적 에너지 성향": .socialType,
            "선호하는 만남 방식": .meetingType,
            "대화 시작 스타일": .chatType,
            "친구 유형 선호도": .friendType,
            "친구 유형 선호": .friendType,
            "관계 목적": .relationType
        ]
    }

    private func personalityOptionLabelMap(for title: String) -> [String: String] {
        switch title {
        case "사회적 에너지 성향":
            return ["EXTROVERT": "외향적", "INTROVERT": "내향적", "OCCASIONAL": "상황에 따라 다름"]
        case "선호하는 만남 방식":
            return ["GROUP": "다인 대화", "ONE": "1:1 대화", "ANY": "무관"]
        case "대화 시작 스타일":
            return ["INITIATOR": "먼저 시작", "RESPONDER": "상대방 주도", "BALANCED": "상호적"]
        case "친구 유형 선호도", "친구 유형 선호":
            return ["SAME_GENDER": "동성", "OPPOSITE_GENDER": "이성", "ANY": "무관"]
        case "관계 목적":
            return [
                "CASUAL": "가벼운 대화",
                "LEARNING": "언어 학습",
                "CULTURE_EXCHANGE": "문화 교류",
                "FRIENDSHIP": "지속적 연락",
                "OFFLINE_MEETUP": "오프라인 교류",
                "TRAVEL_GUIDE": "여행 정보"
            ]
        default:
            return [:]
        }
    }

    private func personalityOptionCodeMap(for title: String) -> [String: String] {
        let labelMap = personalityOptionLabelMap(for: title)
        var codeMap: [String: String] = [:]
        for (code, label) in labelMap {
            codeMap[label] = code
        }
        return codeMap
    }
}

enum PersonalityField {
    case socialType
    case meetingType
    case chatType
    case friendType
    case relationType
}

enum OnboardingError: Error {
    case invalidPersonalitySelection
    case missingLoginContext
    case missingSignupToken
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
