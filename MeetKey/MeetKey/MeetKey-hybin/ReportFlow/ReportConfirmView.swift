//
//  ReportConfirmView.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import SwiftUI

struct ReportConfirmView: View {
    @ObservedObject var homeVM: HomeViewModel
    
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
            Text("신고하기")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
            
            // 3. 안내 문구 (아이콘 + 텍스트)
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "info.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("상대방의 부적절한 행동을 신고해 주세요.")
                    Text("신고 내용은 비공개로 처리되며,\n밋키 운영팀이 검토 후 결과를 안내합니다.")
                }
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.7))
                .lineSpacing(4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            
            // 4. 허위 신고 경고 배너
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("허위 신고 금지")
                        .font(.system(size: 16, weight: .bold))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    bulletPoint(text: "허위 신고 시 서비스 이용 제한이 발생할 수 있습니다.")
                    bulletPoint(text: "신고 내용은 밋키 운영팀이 검토합니다.")
                    bulletPoint(text: "검토 결과는 회원님께 안내됩니다.")
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(16)
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
            
            Spacer()
            
            // 5. 하단 버튼 영역
            HStack(spacing: 12) {
                Button(action: {
                    homeVM.closeReportMenu()
                }) {
                    Text("취소")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                }
                
                Button(action: {
                    // 다음 단계인 신고 사유 선택으로 이동
                    homeVM.changeReportStep(to: .reportCase)
                }) {
                    Text("신고하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.orange)
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
    
    // 불렛 포인트 텍스트 (SubView)
    private func bulletPoint(text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(.gray)
            .lineLimit(1)
    }
}
