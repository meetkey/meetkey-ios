//
//  OtherProfileViewModel.swift
//  MeetKey
//
//  Created by sumin Kong on 2/12/26.
//

import Foundation
import Moya
import SwiftUI
import Combine

final class OtherProfileViewModel: ObservableObject {
    
    @Published var profile: OtherInfoDTO?
    @Published var isLoading: Bool = false
    
    private let provider = MoyaProvider<MyAPI>()
    
    var socialTypeText: String {
        PersonalityOptionMapper.socialType[
            profile?.personalities.socialType ?? ""
        ] ?? ""
    }
    
    var meetingTypeText: String {
        PersonalityOptionMapper.meetingType[
            profile?.personalities.meetingType ?? ""
        ] ?? ""
    }
    
    var chatTypeText: String {
        PersonalityOptionMapper.chatType[
            profile?.personalities.chatType ?? ""
        ] ?? ""
    }
    
    var friendTypeText: String {
        PersonalityOptionMapper.friendType[
            profile?.personalities.friendType ?? ""
        ] ?? ""
    }
    
    var relationTypeText: String {
        PersonalityOptionMapper.relationType[
            profile?.personalities.relationType ?? ""
        ] ?? ""
    }
    
    func fetchOtherProfile(targetId: Int) {
        
        isLoading = true
        
        provider.request(.getOtherInfo(targetId: targetId)) { [weak self] result in
            
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            switch result {
                
            case .success(let response):
                print("✅ statusCode:", response.statusCode)
                
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("📦 response body:\n", jsonString)
                }
                do {
                    let decoded = try JSONDecoder()
                        .decode(OtherInfoResponseDTO.self, from: response.data)
                    
                    DispatchQueue.main.async {
                        self?.profile = decoded.data
                    }
                    
                } catch {
                    print("❌ 디코딩 실패:", error)
                }
                
            case .failure(let error):
                print("❌ 네트워크 실패:", error)
            }
        }
    }
}
