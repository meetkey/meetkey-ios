//
//  InterestEditViewModel.swift
//  MeetKey
//
//  Created by sumin Kong on 2/6/26.
//

import SwiftUI
import Combine
import Moya


final class InterestEditViewModel: ObservableObject {

    @Published var selectedInterests: Set<String>
    @Published var orderedInterests: [(category: String, items: [InterestItemDTO])] = []

    private let provider = MoyaProvider<MyAPI>()

    init(initialInterests: [String] = []) {
        self.selectedInterests = Set(initialInterests)
    }
    
    func fetchMyInterests() {
        provider.request(.getInterest) { result in
            switch result {
            case .success(let response):
                print("📦 statusCode:", response.statusCode)
                print("📦 myInterest_raw data:", String(data: response.data, encoding: .utf8) ?? "nil")
                do {
                    let decoded = try JSONDecoder().decode(MyInterestResponseDTOWrapper.self, from: response.data)
                    let categories = decoded.data.categories
                    DispatchQueue.main.async {
                        self.orderedInterests = categories.map { ($0.category, $0.items) }
                        self.selectedInterests = Set()
                    }
                } catch {
                    print("❌ 관심사 조회 디코딩 실패", error)
                }

            case .failure(let error):
                print("❌ 관심사 조회 실패", error)
            }
        }
    }
    
    func saveInterests(completion: @escaping (Bool) -> Void) {
        let interestsArray = Array(selectedInterests)
        print("📤 저장 요청 interests:", interestsArray)
        let dto = MyInterestEditRequestDTO(interests: interestsArray)
        provider.request(.updateInterest(dto: dto)) { result in
            switch result {
            case .success(let response):
                print("📦 save statusCode:", response.statusCode)
                print("📦 save response:", String(data: response.data, encoding: .utf8) ?? "nil")

                if 200..<300 ~= response.statusCode {
                    DispatchQueue.main.async { completion(true) }
                } else {
                    print("🚫 관심사 저장 실패, statusCode:", response.statusCode)
                }
            case .failure(let error):
                print("❌ 관심사 저장 요청 실패", error)
                DispatchQueue.main.async { completion(false) }
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
    
    var canSave: Bool {
        selectedInterests.count >= 3
    }
}
