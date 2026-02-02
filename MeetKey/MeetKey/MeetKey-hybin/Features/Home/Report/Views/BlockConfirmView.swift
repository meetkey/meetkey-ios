//
//  BlockConfirmView.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import SwiftUI

struct BlockConfirmView: View { 
    @ObservedObject var reportVM: ReportViewModel
    let targetUser: User
    
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
            Text("차단하기")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
            
            // 3. 차단 안내 리스트
            VStack(alignment: .leading, spacing: 0) {
                blockInfoRow(icon: "eye.slash", text: "이 설정을 적용하면 서로의 프로필을 확인할 수 없습니다.")
                
                Divider()
                    .padding(.leading, 64) // 아이콘 너비만큼 여백
                
                blockInfoRow(icon: "message.badge.xmark", text: "상대방은 회원님에게 메시지를 보낼 수 없게 됩니다.")
            }
            .padding(.bottom, 32)
            
            // 4. 신고 바로가기 배너
            Button(action: {
                reportVM.changeReportStep(to: .report) // 신고 단계로 이동
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(Color.orange)
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("상대방이 커뮤니티 가이드라인을 위반했나요?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 4) {
                            Text("신고하러 바로가기")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // 5. 하단 버튼 영역
            HStack(spacing: 12) {
                // 취소 버튼
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
                
                // 차단하기 버튼
                Button(action: {
                    reportVM.confirmBlock(userName: targetUser.name) // VM에서 .blockComplete 단계로 넘김
                }) {
                    Text("차단하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.orange) // 효빈님의 메인 컬러
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
    
    // 안내 문구 행 (SubView)
    private func blockInfoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.gray)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.8))
                .lineSpacing(4)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}
