//
//  PersonalityEditViewModel.swift
//  MeetKey
//
//  Created by sumin Kong on 2/6/26.
//

import SwiftUI
import Combine
import Moya

enum PersonalityKeyMapper {

    static func key(for title: String) -> String? {
        switch title {
        case "사회적 에너지 성향":
            return "socialType"
        case "선호하는 만남 방식":
            return "meetingType"
        case "대화 시작 스타일":
            return "chatType"
        case "친구 유형 선호도":
            return "friendType"
        case "관계 목적":
            return "relationType"
        default:
            return nil
        }
    }
}

enum PersonalityOptionMapper {

    static let socialType: [String: String] = [
        "EXTROVERT": "외향적",
        "INTROVERT": "내향적",
        "OCCASIONAL": "상황에 따라 다름"
    ]

    static let meetingType: [String: String] = [
        "GROUP": "다인 대화",
        "ONE": "1:1 대화",
        "ANY": "무관"
    ]

    static let chatType: [String: String] = [
        "INITIATOR": "먼저 시작",
        "RESPONDER": "상대방 주도",
        "BALANCED": "상호적"
    ]

    static let friendType: [String: String] = [
        "SAME_GENDER": "동성",
        "OPPOSITE_GENDER": "이성",
        "ANY": "무관"
    ]

    static let relationType: [String: String] = [
        "CASUAL": "가벼운 대화",
        "LEARNING": "언어 학습",
        "CULTURE_EXCHANGE": "문화 교류",
        "FRIENDSHIP": "지속적 연락",
        "OFFLINE_MEETUP": "오프라인 교류",
        "TRAVEL_GUIDE": "여행 정보"
    ]
}




final class PersonalityEditViewModel: ObservableObject {
    
    @Published var selectedOptions: [String: String] = [:]
    @Published var personalityOptions: [PersonalitiesDTO] = []
    
    private let provider = MoyaProvider<MyAPI>()
    
    
    func getPersonalities() {
        provider.request(.getPersonality) { result in
            switch result {
            case .success(let response):
                print("📦 statusCode:", response.statusCode)
                print("📦 mypersonality_raw data:", String(data: response.data, encoding: .utf8) ?? "nil")
                do {
                    let decoded = try JSONDecoder().decode(MyPersonalityResponseDTOWrapper.self, from: response.data)
                    DispatchQueue.main.async {
                        self.personalityOptions = decoded.data.categories
                    }
                } catch {
                    print("❌ 성향 조회 디코딩 실패", error)
                }
                
            case .failure(let error):
                print("❌ 성향 조회 실패", error)
            }
        }
    }

    func selectOption(title: String, option: String) {
        guard let key = PersonalityKeyMapper.key(for: title) else {
            assertionFailure("❗️매핑되지 않은 title: \(title)")
            return
        }
        selectedOptions[key] = option
    }
    
    func selectedOption(for title: String) -> String? {
        guard let key = PersonalityKeyMapper.key(for: title) else { return nil }
        return selectedOptions[key]
    }

    var canSave: Bool {
        selectedOptions.count == personalityOptions.count
    }
    
    func makeRequestBody() -> [String: String] {
        selectedOptions
    }
    
    func savePersonalities(completion: @escaping (Bool) -> Void) {
        let body = makeRequestBody()
        let dto = MyPersonalityEditRequestDTO(from: body)

        print("📤 보내는 DTO:", dto)

        provider.request(.updatePersonality(dto: dto)) { result in
            switch result {
            case .success(let response):
                print("✅ 성향 저장 성공:", response.statusCode)
                completion(true)

            case .failure(let error):
                print("❌ 성향 저장 실패:", error)
                completion(false)
            }
        }
    }

    
}

extension PersonalityOptionMapper {

    static func label(for key: String, option: String) -> String {
        switch key {
        case "socialType":
            return socialType[option] ?? option
        case "meetingType":
            return meetingType[option] ?? option
        case "chatType":
            return chatType[option] ?? option
        case "friendType":
            return friendType[option] ?? option
        case "relationType":
            return relationType[option] ?? option
        default:
            return option
        }
    }
}
