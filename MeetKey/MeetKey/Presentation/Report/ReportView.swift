//
//  ReportView.swift
//  MeetKey
//
//  Created by sumin Kong on 2/2/26.
//

import SwiftUI

struct ReportView: View {
//    @State private var isReported = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("신고하기")
                    .font(.meetKey(.title4))
                    .foregroundStyle(.text1)
                    .frame(height: 31)
                Spacer()
            }
            .padding(.leading, 1)
            
            HStack(spacing: 10) {
                VStack {
                    Image(.dangerCircle)
                        .frame(width: 24, height: 24)
                        .padding(.top, 5)
                    Spacer()
                }
                
                Text("상대방의 부적절한 행동을 신고해주세요\n신고 내용은 비공개로 처리되며,\n밋키 운영팀이 검토 후 결과를 안내합니다.")
                    .font(.meetKey(.body3))
                    .foregroundStyle(.text3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 66)
            .padding(.top, 34)
            
            VStack(spacing: 2) {
                HStack(spacing: 5) {
                    Image(.dangerTriangle)
                        .frame(width: 20, height: 20)
                    Text("허위 신고 금지")
                        .font(.meetKey(.body3))
                        .foregroundStyle(.text2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, 14)
                .padding(.leading, 12)
                VStack(alignment: .leading, spacing: 2) {
                    Text("허위 신고 시 서비스 이용 제한이 발생할 수 있습니다.")
                        .font(.meetKey(.caption3))
                        .foregroundStyle(.text3)
                        .frame(height: 17)
                    Text("신고 내용은 밋키 운영팀이 검토합니다.")
                        .font(.meetKey(.caption3))
                        .foregroundStyle(.text3)
                        .frame(height: 17)
                    Text("검토 결과는 회원님께 안내됩니다.")
                        .font(.meetKey(.caption3))
                        .foregroundStyle(.text3)
                        .frame(height: 17)
                }
                .padding(.bottom, 14)
            }
            .frame(height: 107)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.background4, lineWidth: 1)
            )
            .padding(.top, 33)
            HStack(spacing: 6) {
                BlockBtn(title: "취소") {
                }
                .frame(width: 106)
                BlockApplyBtn(title: "신고하기"){
//                    isReported = true
                }
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 24)
//        .navigationDestination(isPresented: $isReported) {
//            BlockCheckView()
//        }
    }
}


#Preview {
    ReportView()
}
