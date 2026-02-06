//
//  InterestEditViewModel.swift
//  MeetKey
//
//  Created by sumin Kong on 2/6/26.
//

import SwiftUI
import Combine

final class InterestEditViewModel: ObservableObject {

    @Published var selectedInterests: Set<String>

    let orderedInterests: [(category: String, items: [String])] = [
        ("일상 · 라이프스타일", [
            "여행", "카페 탐방", "맛집 찾기", "산책", "반려동물",
            "일상 브이로그", "사진찍기", "뜨개질", "미니멀 라이프", "자기계발"
        ]),
        ("문화 · 콘텐츠", [
            "영화", "드라마", "음악", "K-POP", "해외 팝송",
            "넷플릭스", "유튜브", "웹툰/만화", "애니메이션", "게임", "책"
        ]),
        ("지식 · 시사", [
            "언어 공부", "주식", "투자", "뉴스", "사회 이슈",
            "테크/IT", "비즈니스", "디자인", "마케팅", "취업", "커리어"
        ])
    ]

    init(initialInterests: [String]) {
        self.selectedInterests = Set(initialInterests)
    }
    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }
    var canSave: Bool {
        selectedInterests.count >= 3
    }
    var result: [String] {
        Array(selectedInterests)
    }
}
