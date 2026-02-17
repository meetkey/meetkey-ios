//
//  LocationManager.swift
//  MeetKey
//
//  Created by 전효빈 on 2/11/26.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation() // 한 번만 받기
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("\n=== 📍 위치 업데이트 ===")
        print("위도: \(location.coordinate.latitude)")
        print("경도: \(location.coordinate.longitude)")
        print("정확도: \(location.horizontalAccuracy)m")
        print("=====================\n")
        
        currentLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\n❌ 위치 가져오기 실패")
        print("에러: \(error.localizedDescription)")
        print("\n")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ 위치 권한 승인됨")
        case .denied, .restricted:
            print("❌ 위치 권한 거부됨")
        case .notDetermined:
            print("⏳ 위치 권한 대기 중")
        @unknown default:
            break
        }
    }
}
