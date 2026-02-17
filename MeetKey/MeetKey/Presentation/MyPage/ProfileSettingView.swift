//
//  ProfileSettingView.swift
//  MeetKey
//
//  Created by sumin Kong on 2/5/26.
//

import SwiftUI
import PhotosUI

struct ProfileSettingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ProfileSettingViewModel
    
    let onSave: (User) -> Void
    
    init(user: User, onSave: @escaping (User) -> Void) {
        _viewModel = StateObject( wrappedValue: ProfileSettingViewModel(user: user))
        self.onSave = onSave
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("취소")
                    .font(.meetKey(.body2))
                    .foregroundStyle(.text2)
                    .frame(height: 22)
                    .onTapGesture {
                        dismiss()
                    }
                Spacer()
                Text("프로필 변경")
                    .font(.meetKey(.title5))
                    .foregroundStyle(.text1)
                    .frame(height: 24)
                Spacer()
                Text("저장")
                    .font(.meetKey(.body1))
                    .foregroundStyle(.main)
                    .frame(height: 22)
                    .onTapGesture {
                        viewModel.saveProfile { result in
                            switch result {
                            case .success(let updatedUser):
                                onSave(updatedUser)
                                dismiss()
                            case .failure(let error):
                                print("프로필 업데이트 실패:", error)
                            }
                        }
                    }
            }
            .padding(.top, 18)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    ZStack {
                        Group {
                            if let image = viewModel.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                            } else if let url = URL(string: viewModel.user.profileImage) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty: ProgressView()
                                    case .success(let img): img.resizable()
                                    case .failure: Image("defaultProfile").resizable()
                                    @unknown default: Image("defaultProfile").resizable()
                                    }
                                }
                            } else {
                                Image("defaultProfile").resizable()
                            }
                        }
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(
                                LinearGradient(
                                    colors: [.surface31, .surface32],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                        )
                        PhotosPicker(
                            selection: $viewModel.selectedItem,
                            matching: .images
                        ) {
                            Image(.cameraEdit)
                                .padding(.top, 76)
                                .padding(.leading, 72)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .padding(.top, 40)
                    ProfileInfo(title: "이름",
                                context: viewModel.user.name,
                                contextInfo: "이름은 변경할 수 없습니다.")
                    .padding(.top, 20)
                    ProfileInfo(
                        title: "생년월일",
                        context: birthInfo(from: viewModel.user.birthDate),
                        contextInfo: "생년월일은 변경할 수 없습니다."
                    )
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            Text("위치")
                                .font(.meetKey(.body1))
                                .foregroundStyle(.text1)
                                .frame(height: 19)
                            Text("*")
                                .font(.meetKey(.body1))
                                .foregroundStyle(.main)
                                .frame(height: 19)
                            Spacer()
                        }
                        .padding(.bottom, 12)
                        HStack(spacing: 0) {
                            Text(viewModel.user.location)
                                .font(.meetKey(.body3))
                                .foregroundStyle(.text2)
                                .frame(height: 22)
                            Spacer()
                            Image(.location1)
                                .frame(width: 24, height: 24)
                                .onTapGesture {
                                    viewModel.requestCurrentLocation()
                                }
                        }
                        .frame(height: 56)
                        .padding(.horizontal, 18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.disabled, lineWidth: 1)
                        ).frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 2)
                        Text("내 위치 기반으로 등록됩니다.")
                            .font(.meetKey(.caption3))
                            .foregroundStyle(.text04)
                            .frame(height: 17)
                    }
                    .frame(height: 106)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 6)
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            Text("언어 변경")
                                .font(.meetKey(.body1))
                                .foregroundStyle(.text1)
                                .frame(height: 19)
                            Text("*")
                                .font(.meetKey(.body1))
                                .foregroundStyle(.main)
                                .frame(height: 19)
                            Spacer()
                        }
                        .padding(.bottom, 12)
                        Language(
                            usingLanguage: $viewModel.user.first,
                            interestingLanguage: $viewModel.user.target,
                            level: viewModel.user.level
                        )
                        .padding(.bottom, 2)
                    }
                    .frame(height: 149)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 6)
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            Text("한 줄 소개")
                                .font(.meetKey(.body1))
                                .foregroundStyle(.text1)
                                .frame(height: 19)
                            Text("*")
                                .font(.meetKey(.body1))
                                .foregroundStyle(.main)
                                .frame(height: 19)
                            Spacer()
                        }
                        .padding(.bottom, 12)
                        OneLinerSetting(
                            introduceText: $viewModel.oneLinerText
                        )
                        .padding(.bottom, 2)
                    }
                    .frame(height: 109)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(true)
    }
}

extension ProfileSettingView {
    func birthInfo(from birthDate: Date?) -> String {
        guard let birthDate else {
            return "-"
        }
        let calendar = Calendar.current
        let now = Date()
        let age = calendar.dateComponents([.year], from: birthDate, to: now).year ?? 0
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return "만 \(age)세  \(formatter.string(from: birthDate))"
    }
    func saveImageToDocuments(_ image: UIImage) -> URL {
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        let data = image.jpegData(compressionQuality: 0.8)
        try? data?.write(to: url)
        
        return url
    }
}

