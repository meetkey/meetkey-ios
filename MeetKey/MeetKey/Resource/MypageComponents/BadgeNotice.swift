//
//  BadgeNotice.swift
//  MeetKey
//
//  Created by sumin Kong on 1/20/26.
//

import SwiftUI

struct BadgeNotice: View {
    
    var body: some View {
        
        HStack(alignment: .top) {
            Image(.danger)
            .padding(.top, 26)
            .padding(.leading, 12)
            VStack(alignment: .leading, spacing: 0) {
                Text("SAFE 뱃지는 활발한 교류, 본인인증, 미션 참여,")
                    .font(.meetKey(.body5))
                    .foregroundStyle(.black03)
                Text("추천을 기반으로 산정됩니다.")
                    .font(.meetKey(.body5))
                    .foregroundStyle(.black03)
                    .padding(.bottom, 21)
                VStack(alignment: .leading, spacing: 4) {
                    Text("• 브론즈 : 70점 이상")
                    Text("• 실버 : 80점 이상")
                    Text("• 골드 : 90점 이상")
                }
                .font(.meetKey(.caption3))
                .foregroundStyle(.text04)
            }
            .padding(.vertical, 16)
            .padding(.trailing, 12)
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(.FFF_7_ED)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
