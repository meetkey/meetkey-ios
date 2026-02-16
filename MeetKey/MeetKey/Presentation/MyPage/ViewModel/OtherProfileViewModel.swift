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
    
    @Published var reportVM = ReportViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let provider = MoyaProvider<MyAPI>()
    
    init() {
        setupReportViewModel()
    }
    private func setupReportViewModel() {
        reportVM.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        reportVM.onFinalize = { [weak self] in
            print("📍 [HomeVM] Report/Block Finalize Signal Received")
            self?.finalizeReportProcess()
        }
    }
    
    func finalizeReportProcess() {
        withAnimation(.easeInOut) {
            reportVM.closeReportMenu()
        }
    }
    
    var headerUser: User? {
        guard let profile else { return nil }
        
        return User(
            id: profile.memberId,
            name: profile.name,
            profileImage: profile.profileImage,
            age: profile.age,
            gender: profile.gender,
            homeTown: profile.homeTown,
            location: profile.location,
            first: profile.first,
            target: profile.target,
            level: profile.level,
            interests: profile.interests
        )
    }
    
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
