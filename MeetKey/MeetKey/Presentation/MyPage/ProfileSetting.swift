//
//  ProfileSetting.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct ProfileSetting: View {
    
    private var user = User.me // MARK: MeetKey-hybin/Features/HomeViewModel에 목데이터 extension있어요!
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("취소")
                    .font(.meetKey(.body2))
                    .foregroundStyle(.black06)
                    .frame(height: 22)
                Spacer()
                Text("프로필 변경")
                    .font(.meetKey(.title5))
                    .foregroundStyle(.black01)
                    .frame(height: 24)
                Spacer()
                Text("저장")
                    .font(.meetKey(.body1))
                    .foregroundStyle(.main)
                    .frame(height: 22)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    ProfileInfo(title: "이름", context: user.name, contextInfo: "이름은 변경할 수 없습니다.")
                    ProfileInfo(title: "생년월일", context: birthInfo(from: user.birthDate!), contextInfo: "생년월일은 변경할 수 없습니다.")
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("위치")
                                .font(.meetKey(.body1))
                                .foregroundStyle(.black01)
                                .frame(height: 19)
                            Spacer()
                        }
                        .padding(.bottom, 12)
                        HStack(spacing: 0) {
                            Text(user.location!)
                                .font(.meetKey(.body3))
                                .foregroundStyle(.black06)
                                .frame(height: 22)
                            Spacer()
                            Image(.location1)
                                .frame(width: 24, height: 24)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.disabled, lineWidth: 1)
                        )
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
                        HStack {
                            Text("언어 변경")
                                .font(.meetKey(.body1))
                                .foregroundStyle(.black01)
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
                        HStack {
                            Text("한 줄 소개")
                                .font(.meetKey(.body1))
                                .foregroundStyle(.black01)
                                .frame(height: 19)
                            Spacer()
                        }
                        .padding(.bottom, 12)
                        OneLiner(introduceText: user.oneLiner)
                        .padding(.bottom, 2)
                    }
                    .frame(height: 109)
                    .frame(maxWidth: .infinity)
                    
                }
                
            }
            
            
            
            
        }
        .padding(.horizontal, 20)
    }
}


//MARK: - User모델에 계산 파트에 따로 만들어놨어요
extension ProfileSetting {
    func birthInfo(from birthDate: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let age = calendar.dateComponents([.year], from: birthDate, to: now).year ?? 0
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let dateString = formatter.string(from: birthDate)
        
        return "만 \(age)세  \(dateString)"
    }
}

#Preview {
    ProfileSetting()
}

