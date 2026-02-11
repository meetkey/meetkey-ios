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

final class ProfileSettingViewModel: ObservableObject {
    
    @Published var user: User
    @Published var oneLinerText: String
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var provider = MoyaProvider<MyAPI>()
    
    init(user: User) {
        self.user = user
        self.oneLinerText = user.bio ?? ""
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
