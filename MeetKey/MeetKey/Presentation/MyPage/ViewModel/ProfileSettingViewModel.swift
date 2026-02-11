//
//  ProfileSettingViewModel.swift
//  MeetKey
//
//  Created by sumin Kong on 2/11/26.
//

import SwiftUI
import PhotosUI
import Combine

final class ProfileSettingViewModel: ObservableObject {

    @Published var user: User
    @Published var oneLinerText: String
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?

    init(user: User) {
        self.user = user
        self.oneLinerText = user.bio ?? ""
    }

    func loadSelectedImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.selectedImage = uiImage
                }
            }
        }
    }
    
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
