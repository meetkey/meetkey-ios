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
    @Binding var user: User
    
    @State private var oneLinerText: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
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
                        if let selectedImage {
                            let url = saveImageToDocuments(selectedImage)
                            user.profileImage = url.lastPathComponent
                        }
                        user.bio = oneLinerText
                        dismiss()
                    }
            }
            .padding(.top, 18)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    ZStack {
                        Group {
                            if let selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                            } else {
                                Image(user.profileImage)
                                    .resizable()
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
                            selection: $selectedItem,
                            matching: .images
                        ) {
                            Image(.cameraEdit)
                                .padding(.top, 76)
                                .padding(.leading, 72)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .padding(.top, 40)
                    ProfileInfo(title: "이름", context: user.name, contextInfo: "이름은 변경할 수 없습니다.")
                        .padding(.top, 20)
                    ProfileInfo(
                        title: "생년월일",
                        context: birthInfo(from: user.birthDate),
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
                            Text(user.location)
                                .font(.meetKey(.body3))
                                .foregroundStyle(.text2)
                                .frame(height: 22)
                            Spacer()
                            Image(.location1)
                                .frame(width: 24, height: 24)
                                .onTapGesture {
                                    user.location = "현재 위치"
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
                        Language(isSetting: true)
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
                        OneLinerSetting(introduceText: $oneLinerText)
                        .padding(.bottom, 2)
                    }
                    .frame(height: 109)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            oneLinerText = user.oneLiner
        }
        .onChange(of: selectedItem) { newItem in
            guard let newItem else { return }

            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
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

