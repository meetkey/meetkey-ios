//
//  InterestEditViewModel.swift
//  MeetKey
//
//  Created by sumin Kong on 2/6/26.
//

import SwiftUI
import Combine
import Moya

struct InterestItem: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
}

final class InterestEditViewModel: ObservableObject {

    @Published var selectedInterests: Set<String> = []

    var orderedInterests: [(category: String, items: [String])] = [
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
    
    private let provider = MoyaProvider<MyAPI>()

    init(initialInterests: [String]) {
        self.selectedInterests = Set(initialInterests)
    }
    
    func fetchMyInterests() {
        provider.request(.getInterest) { result in
            switch result {
            case .success(let response):
                print("📦 statusCode:", response.statusCode)
                print("📦 raw data:", String(data: response.data, encoding: .utf8) ?? "nil")
                do {
                    let decoded = try JSONDecoder().decode(
                        MyInterestResponseDTO.self,
                        from: response.data
                    )
                    
                    let codes = decoded.categories.flatMap { $0.items}.map{$0.code}
                    
                    DispatchQueue.main.async {
                        self.selectedInterests = Set(codes)
                    }
                } catch {
                    print("❌ 관심사 조회 디코딩 실패", error)
                }

            case .failure(let error):
                print("❌ 관심사 조회 실패", error)
            }
        }
    }
    
    func toggleInterest(code: String) {
        if selectedInterests.contains(code) {
            selectedInterests.remove(code)
        } else {
            selectedInterests.insert(code)
        }
    }
    
//    func toggleInterest(_ interest: String) {
//        if selectedInterests.contains(interest) {
//            selectedInterests.remove(interest)
//        } else {
//            selectedInterests.insert(interest)
//        }
//    }
    var canSave: Bool {
        selectedInterests.count >= 3
    }
    var result: [String] {
        Array(selectedInterests)
    }
}
