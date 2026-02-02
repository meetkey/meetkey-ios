//
//  ReportCompleteView.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import SwiftUI

struct ReportCompleteView: View {
    @ObservedObject var reportVM: ReportViewModel
    let targetUser: User
    var body: some View {
        ZStack {
            // ✅ 배경 이미지 에셋 처리 영역 (주석 해제 후 사용)
            /*
            Image("report_complete_bg") // 에셋 이름을 넣어주세요
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .opacity(0.1)
                .padding(.bottom, 100)
            */
            
            VStack(alignment: .leading, spacing: 0) {
                // 1. 상단 핸들
                HStack {
                    Spacer(); Capsule().fill(Color.gray.opacity(0.2)).frame(width: 40, height: 4); Spacer()
                }
                .padding(.vertical, 12)
                
                // 2. 타이틀 (체크 아이콘 + 텍스트)
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.orange)
                    
                    Text("신고 완료")
                        .font(.system(size: 24, weight: .bold))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // 3. 안내 문구 설명
                VStack(alignment: .leading, spacing: 24) {
                    Text("신고가 정상적으로 접수되었습니다.\n회원님의 신고는 안전한 이용 환경 조성에\n반영됩니다.")
                        .font(.system(size: 16))
                        .lineSpacing(6)
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text("밋키 운영팀이 내용을 확인한 후\n처리 결과를 안내해드리겠습니다.\n감사합니다.")
                        .font(.system(size: 16))
                        .lineSpacing(6)
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                Spacer() // 이미지 배치를 위한 여백
                
                // 4. 하단 확인 버튼
                Button(action: {
                    // 확인 클릭 시 모든 신고/차단 프로세스 종료 및 시트 닫기
                    reportVM.finalizeReportProcess()
                }) {
                    Text("확인")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.orange)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .frame(maxHeight: .infinity)
    }
}
