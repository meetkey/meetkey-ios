//
//  BlockCompleteView.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import SwiftUI

struct BlockCompleteView: View {
    @ObservedObject var homeVM: HomeViewModel
    
    var body: some View {
        ZStack {
            // 배경 이미지 에셋 처리 영역
            /*
            Image("your_asset_name") // 여기에 에셋 이름을 넣어주세요
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .opacity(0.1) // 배경처럼 은은하게 깔릴 경우
                .padding(.bottom, 100) // 하단 버튼과의 간격 조절
            */
            
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
                
                // 2. 타이틀 영역 (체크 아이콘 + 텍스트)
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.orange) // 오렌지색 포인트
                    
                    Text("차단 완료")
                        .font(.system(size: 24, weight: .bold))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // 3. 안내 문구 설명
                VStack(alignment: .leading, spacing: 24) {
                    Text("상대방을 차단했습니다.\n서로의 프로필을 확인할 수 없으며,\n추천 친구 목록에도 표시되지 않습니다.")
                        .font(.system(size: 16))
                        .lineSpacing(6)
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text("또한 상대방은 회원님에게\n메시지를 보낼 수 없습니다.")
                        .font(.system(size: 16))
                        .lineSpacing(6)
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                Spacer() // 이미지가 들어갈 공간을 위해 밀어주기
                
                // 4. 하단 확인 버튼
                Button(action: {
                    // 확인 클릭 시 시트 닫고 다음 유저로 넘기기
                    homeVM.finalizeReportProcess()
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
