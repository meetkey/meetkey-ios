//
//  ReportCaseView.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import SwiftUI

struct ReportCaseView: View {
    @ObservedObject var homeVM: HybinHomeViewModel
    
    // 피그마에 정의된 신고 카테고리 목록
    private let categories = [
        "부적절한 행동 신고",
        "긴급한 위험 상황",
        "서비스 이용에 부적합한 행위",
        "성희롱 또는 불쾌감을 주는 행동",
        "혐오·차별적 발언"
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
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            // 선택한 카테고리를 저장하고 다음 단계로 이동
                            // homeVM.selectedReportCategory = category (필요 시 추가)
                            homeVM.changeReportStep(to: .reportReason)
                        }) {
                            HStack {
                                Text(category)
                                    .font(.system(size: 18))
                                    .foregroundColor(.black.opacity(0.8))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 24)
                            .contentShape(Rectangle()) // 투명한 영역도 클릭 가능하게
                        }
                        
                        Divider()
                            .padding(.horizontal, 24)
                    }
                }
            }
            
            // 4. 하단 버튼 영역 (디자인상 비활성화 상태인 경우)
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
                
                Button(action: {}) { // 리스트 클릭 시 이동하므로 여기선 비활성 느낌
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
