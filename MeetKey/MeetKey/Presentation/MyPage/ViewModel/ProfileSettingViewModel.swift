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
    
    @Published var selectedItem: PhotosPickerItem? {
        didSet {
            if let item = selectedItem {
                loadSelectedImage(from: item)
            }
        }
    }
    @Published var selectedImage: UIImage?
    
    @Published var currentLatitude: Double = 0
    @Published var currentLongitude: Double = 0
    
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
    
    private func loadSelectedImage(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data,
                       let uiImage = UIImage(data: data) {
                        self?.selectedImage = uiImage
                    }
                case .failure(let error):
                    print("이미지 로드 실패:", error)
                }
            }
        }
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
            latitude: currentLatitude,
            longitude: currentLongitude,
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
    
    func uploadProfileImage(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8)
        else {
            completion(.failure(NSError(domain: "ImageError", code: 0)))
            return
        }
        
        let fileName = UUID().uuidString + ".jpg"
        
        let requestDTO = [
            ImageUploadRequestDTO(
                fileName: fileName,
                contentType: "image/jpeg"
            )
        ]
        
        provider.request(.getURLForImageUpload(dto: requestDTO)) { [weak self] result in
            
            switch result {
                
            case .success(let response):
                do {
                    let decoded = try JSONDecoder()
                        .decode(ImageUploadResponseDTO.self, from: response.data)
                    
                    guard let uploadInfo = decoded.data.first else {
                        completion(.failure(NSError(domain: "NoData", code: 0)))
                        return
                    }
                    
                    self?.uploadToS3(
                        uploadURL: uploadInfo.url,
                        imageData: imageData,
                        key: uploadInfo.key,
                        imageURL: uploadInfo.url.components(separatedBy: "?").first ?? "",
                        completion: completion
                    )
                    
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func uploadToS3(
        uploadURL: String,
        imageData: Data,
        key: String,
        imageURL: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        guard let url = URL(string: uploadURL) else {
            completion(.failure(NSError(domain: "BadURL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "S3UploadFail", code: 0)))
                return
            }
            
            // key DB 저장
            self?.registerImageKey(
                keys: [key],
                imageURL: imageURL,
                completion: completion
            )
        }.resume()
    }
    
    
    private func registerImageKey(
        keys: [String],
        imageURL: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        provider.request(.registerProfileImages(keys: keys)) { [weak self] result in
            
            switch result {
                
            case .success:
                DispatchQueue.main.async {
                    if var currentUser = self?.user {
                        currentUser.profileImage = imageURL
                        self?.user = currentUser
                    }
                    print("🔥 최종 profileImage:", self?.user.profileImage ?? "nil")
                }
                
                print("🔥 이미지 key 저장 완료")
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func saveProfile(completion: @escaping (Result<User, Error>) -> Void) {
        print("🔥 saveProfile 진입")
        // 이미지가 선택된 경우
        if selectedImage != nil {
            uploadProfileImage { [weak self] result in
                switch result {
                case .success:
                    print("✅ 이미지 업로드 완료 → updateProfile 실행")
                    self?.updateProfile(completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // 이미지 변경 없으면 바로 프로필 업데이트
            updateProfile(completion: completion)
        }
    }
    
    func applyChanges() {
        user.bio = oneLinerText
    }
}


extension ProfileSettingViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        self.currentLatitude = latitude
        self.currentLongitude = longitude
        
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
