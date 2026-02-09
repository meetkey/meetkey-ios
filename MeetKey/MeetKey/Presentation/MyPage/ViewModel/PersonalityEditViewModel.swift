//
//  PersonalityEditViewModel.swift
//  MeetKey
//
//  Created by sumin Kong on 2/6/26.
//

import SwiftUI
import Combine

final class PersonalityEditViewModel: ObservableObject {
    
    @Published var selectedOptions: [WritableKeyPath<Personalities, String>: String]
    
    let personalityQuestions: [(keyPath: WritableKeyPath<Personalities, String>, question: String, options: [String])] = [
        (\Personalities.socialType, "사회적 에너지 성향", ["외향적", "내향적", "상황에 따라 다름"]),
        (\Personalities.meetingType, "선호하는 만남 방식", ["다인 대화", "1:1 대화", "무관"]),
        (\Personalities.chatType, "대화 시작 스타일", ["먼저 시작", "상대방 주도", "상호적"]),
        (\Personalities.friendType, "친구 유형 선호", ["동성", "이성", "무관"]),
        (\Personalities.relationType, "관계 목적", ["가벼운 대화", "언어 학습", "문화 교류", "지속적 연락", "오프라인 교류", "여행 정보"])
    ]
    
    init(initialSelections: [WritableKeyPath<Personalities, String>: String] = [:]) {
        self.selectedOptions = initialSelections
    }

    func selectOption(keyPath: WritableKeyPath<Personalities, String>, option: String) {
        selectedOptions[keyPath] = option
    }

    var canSave: Bool {
        selectedOptions.count == personalityQuestions.count
    }
    
    func toPersonalities(existing: Personalities? = nil) -> Personalities {
        var p = existing ?? Personalities(
            socialType: "",
            meetingType: "",
            chatType: "",
            friendType: "",
            relationType: ""
        )
        
        for (keyPath, value) in selectedOptions {
            p[keyPath: keyPath] = value
        }
        return p
    }
    
    
}

