import SwiftUI
import Combine

// 데이터 모델
struct OnboardingData {
    var hometown: String?
    var nativeLanguage: String?
    var targetLanguage: String?
    var proficiency: String?
    
    // 기본 정보
    var name: String = ""
    var birthDateString: String = ""
    var gender: String?
    
    // 사진
    var profileImageURLs: [String] = []
    
    // 관심사 (중복 방지 Set)
    var interests: Set<String> = []
    
    // [사용] 성향 (Key: 질문, Value: 답변)
    var personality: [String: String] = [:]
}

class OnboardingViewModel: ObservableObject {
    @Published var data = OnboardingData()
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
    
    // 사진 관련
    @Published var profileImages: [Int: UIImage] = [:]
    @Published var showImageActionSheet: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @Published var selectedImageIndex: Int? = nil
    
    // Step 4. 관심사 (Interest)
    // 관심사 데이터 (순서 보장)
    let orderedInterests: [(category: String, items: [String])] = [
        ("일상 · 라이프스타일", ["여행", "카페 탐방", "맛집 찾기", "산책", "반려동물", "일상 브이로그", "사진찍기", "뜨개질", "미니멀 라이프", "자기계발"]),
        ("문화 · 콘텐츠", ["영화", "드라마", "음악", "K-POP", "해외 팝송", "넷플릭스", "유튜브", "웹툰/만화", "애니메이션", "게임", "책"]),
        ("지식 · 시사", ["언어 공부", "주식", "투자", "뉴스", "사회 이슈", "테크/IT", "비즈니스", "디자인", "마케팅", "취업", "커리어"])
    ]
    
    // 관심사 선택/해제
    func toggleInterest(_ interest: String) {
        if data.interests.contains(interest) {
            data.interests.remove(interest)
        } else {
            data.interests.insert(interest)
        }
    }
    
    // Step 5. 성향 (Personality)
    // 성향 질문 및 선택지 데이터
    let personalityQuestions: [(question: String, options: [String])] = [
        ("사회적 에너지 성향", ["외향적", "내향적", "상황에 따라 다름"]),
        ("선호하는 만남 방식", ["다인 대화", "1:1 대화", "무관"]),
        ("대화 시작 스타일", ["먼저 시작", "상대방 주도", "상호적"]),
        ("친구 유형 선호", ["동성", "이성", "무관"]),
        ("관계 목적", ["가벼운 대화", "언어 학습", "문화 교류", "지속적 연락", "오프라인 교류", "여행 정보"])
    ]
    
    // 성향 선택 로직 (질문당 하나만 선택 가능)
    func selectPersonality(question: String, option: String) {
        // 딕셔너리에 저장 (Key: 질문, Value: 선택한 옵션)
        // 이미 값이 있으면 덮어씌워짐 -> 단일 선택 효과
        data.personality[question] = option
    }
    
    // 검증 로직들 (Validation)
    // 1. 기본 정보 완료 여부
    var isBasicInfoCompleted: Bool {
        return data.hometown != nil && data.nativeLanguage != nil && data.targetLanguage != nil
    }
    
    // 2. 프로필 정보 완료 여부 (이름/생일/성별)
    var isProfileInfoCompleted: Bool {
        return !data.name.isEmpty && !data.birthDateString.isEmpty && data.gender != nil
    }
    
    // 3. 사진 등록 완료 여부 (3장 필수)
    var isProfileImagesCompleted: Bool {
        return profileImages.count == 3
    }
    
    // 4. 관심사 선택 완료 여부 (각 카테고리별 3개 이상)
    var isInterestSelectionCompleted: Bool {
        for group in orderedInterests {
            // 해당 카테고리(group)에 속한 아이템 중 선택된 것의 개수를 셈
            let selectedCount = group.items.filter { data.interests.contains($0) }.count
            
            // 만약 어느 한 카테고리라도 3개 미만이면 false 리턴
            if selectedCount < 3 {
                return false
            }
        }
        // 모든 카테고리가 3개 이상이면 true
        return true
    }
    
    // 5. 성향 선택 완료 여부 (모든 질문에 답했는지 확인)
    var isPersonalitySelectionCompleted: Bool {
        // 질문의 개수와 저장된 답변의 개수가 같아야 함
        return data.personality.count == personalityQuestions.count
    }
    
    // 🛠️ 기타 헬퍼
    var birthdayDisplayString: String {
        guard let date = birthday else { return "YYYY/MM/DD" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    // 더미 데이터
    let countries = ["USA", "UK", "China", "Japan", "Korea", "France", "Germany", "Italy", "Spain"]
    let languages = ["영어 (English)", "한국어 (한국어)", "중국어 (中國語)", "일본어 (日本語)", "스페인어 (Español)", "프랑스어 (Français)", "독일어 (Deutsch)", "이탈리아어 (Italiano)", "러시아어 (Pусский)"]
}
