//
//  ProfileSettingViewModel.swift
//  MeetKey
//
//  Created by sumin Kong on 2/11/26.
//

import SwiftUI
import PhotosUI
import Combine
import Moya
import CoreLocation

final class ProfileSettingViewModel: NSObject, ObservableObject {
    
    @Published var user: User
    @Published var oneLinerText: String
    @Published var locationString: String = ""
    
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    private var provider = MoyaProvider<MyAPI>()
    
    init(user: User) {
        self.user = user
        self.oneLinerText = user.bio ?? ""
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestCurrentLocation() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            print("❌ 위치 권한 거부됨")
            openAppSettings()
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            
        @unknown default:
            break
        }
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func updateLocationToServer(latitude: Double, longitude: Double) {
        
        let dto = MyLocationRequestDTO(
            latitude: latitude,
            longitude: longitude
        )
        
        provider.request(.updateMyLocation(dto: dto)) { result in
            switch result {
            case .success(let response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    print("✅ 서버 위치 업데이트 성공")
                } catch {
                    print("❌ 서버 응답 에러:", error)
                }
                
            case .failure(let error):
                print("❌ 네트워크 에러:", error)
            }
        }
    }
    
    private func reverseGeocode(latitude: Double, longitude: Double) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let placemark = placemarks?.first {
                
                let address = [
                    placemark.administrativeArea,
                    placemark.locality,
                    placemark.subLocality
                ]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                DispatchQueue.main.async {
                    self.locationString = address
                    self.user.location = address
                }
            }
        }
    }
    
    func updateProfile(completion: @escaping (Result<User, Error>) -> Void) {
        applyChanges()
        
        let dto = MyProfileSettingsRequestDTO(
            location: user.location,
            latitude: 0,  // 여기 실제 Double 값 필요
            longitude: 0, // 실제 Double 값 필요
            bio: user.bio ?? "",
            first: user.first,
            target: user.target,
            level: user.level
        )
        provider.request(.updateMyProfileSettings(dto: dto)) { result in
            switch result {
            case .success(let response):
                print("📦 save statusCode:", response.statusCode)
                print("📦 save response:", String(data: response.data, encoding: .utf8) ?? "nil")
                
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    print("프로필 업데이트 성공")
                    completion(.success(self.user))
                } catch {
                    print("프로필 업데이트 실패: \(error)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("프로필 업데이트 실패: \(error)")
                completion(.failure(error))
            }
        }
        
        
    }
    
    //    func loadSelectedImage(from item: PhotosPickerItem?) {
    //        guard let item else { return }
    //
    //        Task {
    //            if let data = try? await item.loadTransferable(type: Data.self),
    //               let uiImage = UIImage(data: data) {
    //                await MainActor.run {
    //                    self.selectedImage = uiImage
    //                }
    //            }
    //        }
    //    }
    //
    
    
    func applyChanges() {
        user.bio = oneLinerText
        
        if let selectedImage {
            let url = saveImageToDocuments(selectedImage)
            user.profileImage = url.lastPathComponent
        }
    }
    
    private func saveImageToDocuments(_ image: UIImage) -> URL {
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url)
        }
        
        return url
    }
    
}

extension ProfileSettingViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        print("📍 현재 좌표:", latitude, longitude)
        
        reverseGeocode(latitude: latitude, longitude: longitude)
        updateLocationToServer(latitude: latitude, longitude: longitude)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("❌ 위치 가져오기 실패:", error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
