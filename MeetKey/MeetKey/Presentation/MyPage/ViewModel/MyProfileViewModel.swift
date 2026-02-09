//
//  MyProfileViewModel.swift
//  MeetKey
//
//  Created by sumin Kong on 2/9/26.
//
import SwiftUI
import Combine
import Moya

final class MyProfileViewModel: ObservableObject {
    @Published var user: User?
    
    private let provider = MoyaProvider<MyAPI>()
    func fetchMyProfile() {
        provider.request(.myInfo) { result in
            switch result {
            case .success(let response):
                print("📦 statusCode:", response.statusCode)
                print("📦 raw data:", String(data: response.data, encoding: .utf8) ?? "nil")
                guard response.statusCode == 200 else {
                    print("🚫 인증 필요 or 권한 없음")
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(
                        MyInfoResponseDTO.self,
                        from: response.data
                    )
                    let user = User(dto: decoded.data)
                    
                    DispatchQueue.main.async {
                        self.user = user
                    }
                } catch {
                    print("❌ 디코딩 실패:", error)
                }
                
            case .failure(let error):
                print("❌ 내 프로필 요청 실패:", error)
            }
        }
    }
}
