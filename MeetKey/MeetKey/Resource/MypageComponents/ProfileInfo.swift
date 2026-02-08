//
//  ProfileInfo.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct ProfileInfo: View {
    var title: String = "Profile Info"
    var context: String
    var birthday: String = Date().formatted(.dateTime)
    var contextInfo: String = "Context Info"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.meetKey(.body1))
                    .foregroundStyle(.text1)
                    .frame(height: 19)
                Spacer()
            }
            .padding(.bottom, 12)
            Text(context)
                .font(.meetKey(.body3))
                .foregroundStyle(.text04)
                .padding(.horizontal, 18)
                .frame(height: 56)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.background1)
                )
                .padding(.bottom, 2)
            Text(contextInfo)
                .font(.meetKey(.caption3))
                .foregroundStyle(.text04)
                .frame(height: 17)
        }
        .frame(height: 106)
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    var user = MyPageUser(
        name: "김밋키",
        birthDate: Date(),
        location: "서울",
        usingLanguage: "Korean",
        interestingLanguage: "English",
        oneLiner: "여행을 사랑하고 새로운 음식을 시도해보는 것을 좋아해요! 문화 교류와 언어 교환에 진심인 사람을 찾고 있어요!🌎✨"
    )
    ProfileInfo(
        title: "이름",
        context: user.name,
        contextInfo: "이름은 변경할 수 없습니다."
    )
}

