//
//  SafeBadgeRecordViewModel.swift
//  MeetKey
//
//  Created by sumin Kong on 2/17/26.
//

import Foundation
import Moya
import Combine

final class SafeBadgeRecordViewModel: ObservableObject {
    
    @Published var badge: BadgeDTO?
    @Published var isLoading: Bool = false
    
    private let provider = MoyaProvider<BadgeAPI>()
    
    func fetchBadgeRecord() {
        isLoading = true
        
        provider.request(.getMyBadgeRecord) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            switch result {
                
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(
                        BadgeHistoryResponseDTO.self,
                        from: response.data
                    )
                    
                    DispatchQueue.main.async {
                        self?.badge = decoded.data
                    }
                    
                } catch {
                    print("❌ BadgeDTO 디코딩 실패:", error)
                }
                
            case .failure(let error):
                print("❌ Badge 기록 조회 실패:", error)
            }
        }
    }
}
