//
//  ReportReasonView.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import SwiftUI
import PhotosUI // 사진 첨부를 위해 필요

struct ReportReasonView: View {
    @ObservedObject var reportVM: ReportViewModel
    let targetUser: User
    
//    @State private var reportText: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. 상단 핸들
            HStack {
                Spacer(); Capsule().fill(Color.gray.opacity(0.2)).frame(width: 40, height: 4); Spacer()
            }
            .padding(.vertical, 12)
            
            // 2. 타이틀 (선택한 카테고리명을 동적으로 보여주면 더 좋아요)
            Text("부적절한 행동 신고")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            
            // 3. 텍스트 입력 영역
            ZStack(alignment: .topLeading) {
                TextEditor(text: $reportVM.reportReason)
                    .frame(height: 150)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
                
                if reportVM.reportReason.isEmpty {
                    Text("상대방의 발언 및 행동이 커뮤니티 가이드라인에\n부합하지 않는다고 판단되어 신고를 접수합니다.")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            
            // 4. 사진/동영상 첨부하기 영역
            VStack(alignment: .leading, spacing: 12) {
                Text("사진/동영상 첨부하기")
                    .font(.system(size: 18, weight: .bold))
                
                HStack(spacing: 12) {
                    // 사진 선택 버튼
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .images) {
                        VStack {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // 선택된 이미지 미리보기 (생략 가능, 여기선 디자인대로 + 버튼 유지)
                    ForEach(0..<2) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                            .frame(width: 80, height: 80)
                            .overlay(Image(systemName: "plus").foregroundColor(.gray))
                    }
                }
                
                Text("최대 3개 업로드 가능합니다.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // 5. 하단 버튼 영역
            HStack(spacing: 12) {
                Button("취소") { reportVM.closeReportMenu() }
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Color.gray.opacity(0.1)).cornerRadius(16)
                    .foregroundColor(.gray)
                
                Button("신고하기") {
                    reportVM.changeReportStep(to: .reportComplete) // 완료 단계로 이동
                    reportVM.confirmReport(targetId: targetUser.id, userName: targetUser.name)
                }
                .frame(maxWidth: .infinity).frame(height: 56)
                .background(Color.orange).cornerRadius(16)
                .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        // 사진 선택 시 이미지로 변환하는 로직
        .onChange(of: selectedItems) { newValue in
            Task {
                selectedImages.removeAll()
                for item in newValue {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
}
