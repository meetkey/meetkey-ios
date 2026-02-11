//
//  ReportCaseView.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import SwiftUI

struct ReportCaseView: View {
    @ObservedObject var reportVM: ReportViewModel
    let targetUser: User
    // 피그마에 정의된 신고 카테고리 목록
    private let categories = [
        "부적절한 행동 신고",
        "긴급한 위험 상황",
        "서비스 이용에 부적합한 행위",
        "성희롱 또는 불쾌감을 주는 행동",
        "혐오·차별적 발언",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. 상단 핸들 (시트 인디케이터)
            HStack {
                Spacer()
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 4)
                Spacer()
            }
            .padding(.vertical, 12)

            // 2. 타이틀
            Text("어떤 사유로 신고하나요?")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

            // 3. 신고 카테고리 리스트
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(ReportType.allCases, id: \.self) { type in
                        Button(action: {
                            reportVM.selectedType = type
                            reportVM.changeReportStep(to: .reportReason)
                        }) {
                            HStack {
                                Text(type.displayName)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 24)
                        }

                        Divider()
                            .padding(.horizontal, 24)
                    }
                }
            }

            // 4. 하단 버튼 영역 (디자인상 비활성화 상태인 경우)
            HStack(spacing: 12) {
                Button(action: {
                    reportVM.closeReportMenu()
                }) {
                    Text("취소")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                }

                Button(action: {}) {
                    Text("신고하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(16)
                }
                .disabled(true)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .padding(.top, 20)
        }
    }
}
