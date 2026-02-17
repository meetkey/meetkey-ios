//
//  VoiceCallView.swift
//  MeetKey
//
//  Created by sumin Kong on 2/4/26.
//

import SwiftUI

struct VoiceCallView: View {
    @Environment(\.dismiss) private var dismiss

    var profileImage: Image? = Image(.meetKeyCharacter)
    var userName: String = "Jane Smith"
    var userBadge: BadgeType
    var callState: String = "연결중"
    
    var body: some View {
        ZStack {
            Image(.voiceBackground)
                .resizable()
                .ignoresSafeArea(edges: .all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 0) {
                profileImage?
                    .resizable()
                    .scaledToFill()
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.surface31, .surface32],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .padding(.top, 149)

                HStack(spacing: 4) {
                    Text(userName)
                        .font(.meetKey(.title4))
                        .foregroundStyle(.text1)
                        .frame(height: 31)
                    Image(userBadge.rawValue)
                }
                .padding(.top, 24)

                Text(callState)
                    .font(.meetKey(.body3))
                    .foregroundStyle(.text3)
                    .frame(height: 22)
                    .padding(.top, 6)

                HStack(spacing: 24) {
                    Button {
                        dismiss()
                    } label: {
                        VStack(spacing: 5) {
                            Image(.voiceBack)
                            Text("돌아가기")
                                .font(.meetKey(.body5))
                                .foregroundStyle(.text3)
                                .frame(height: 20)
                        }
                    }

                    Button {
                        // action
                    } label: {
                        VStack(spacing: 5) {
                            Image(.voiceMute)
                            Text("음소거")
                                .font(.meetKey(.body5))
                                .foregroundStyle(.text3)
                                .frame(height: 20)
                        }
                    }

                    Button {
                        // action
                    } label: {
                        VStack(spacing: 5) {
                            Image(.voice)
                            Text("스피커")
                                .font(.meetKey(.body5))
                                .foregroundStyle(.text3)
                                .frame(height: 20)
                        }
                    }
                }
                .padding(.top, 148)
                
                Button {
                    // ✅ 통화 종료(현재 화면 닫기)
                    dismiss()
                } label: {
                    Image(.call)
                }
                .padding(.top, 59)
                .padding(.bottom, 14)
            }
        }
    }
}

#Preview {
    VoiceCallView(userBadge: .gold)
}
