//
//  LocationService.swift
//  MeetKey
//
//  Created by 전효빈 on 2/11/26.
//

import Foundation

class LocationService {
    static let shared = LocationService()
    
    private let networkProvider = NetworkProvider.shared
    
    private init() {}
    
    func updateMyLocation(latitude: Double, longitude: Double) async throws {
        print("📍 위치 업데이트 요청: lat=\(latitude), lng=\(longitude)")
        
        try await withCheckedThrowingContinuation { continuation in
            networkProvider.requestLocation(
                .updateLocation(latitude: latitude, longitude: longitude),
                type: Bool.self
            ) { result in
                switch result {
                case .success:
                    print("✅ 위치 업데이트 성공")
                    continuation.resume(returning: ())
                case .failure(let error):
                    print("❌ 위치 업데이트 실패: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
