import SwiftUI
import PhotosUI

struct ReportReasonView: View {
    @ObservedObject var reportVM: ReportViewModel
    let targetUser: User
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(reportVM.selectedType.displayName)
                .font(.meetKey(.title4))
                .foregroundStyle(.text1)
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 24)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $reportVM.reportReason)
                    .font(.meetKey(.body3))
                    .scrollContentBackground(.hidden)
                    .padding(16)
                    .frame(height: 154)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.background1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.background4, lineWidth: 1)
                    )
                
                if reportVM.reportReason.isEmpty {
                    Text("상대방의 발언 및 행동이 커뮤니티 가이드라인에\n부합하지 않는다고 판단되어 신고를 접수합니다.")
                        .font(.meetKey(.body5))
                        .foregroundStyle(.text3)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 24)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("사진/동영상 첨부하기")
                    .font(.meetKey(.title5))
                    .foregroundStyle(.text1)
                
                HStack(spacing: 12) {
                    if selectedImages.count < 3 {
                        PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .images) {
                            VStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.text3)
                                Text("\(selectedImages.count)/3")
                                    .font(.meetKey(.caption3))
                                    .foregroundStyle(.text3)
                            }
                            .frame(width: 80, height: 80)
                            .background(.background2)
                            .cornerRadius(12)
                        }
                    }
                    
                    ForEach(0..<selectedImages.count, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Button {
                                removeImage(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.white)
                                    .background(Circle().fill(.black.opacity(0.5)))
                            }
                            .padding(4)
                        }
                    }
                }
                
                Text("최대 3개 업로드 가능합니다.")
                    .font(.meetKey(.caption3))
                    .foregroundStyle(.text3)
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)
            
            Spacer()
            
            HStack(spacing: 6) {
                BlockBtn(title: "취소") {
                    reportVM.closeReportMenu()
                }
                .frame(width: 106)
                
                BlockApplyBtn(title: "신고하기") {
                    reportVM.confirmReport(targetId: targetUser.id, userName: targetUser.name)
                    reportVM.changeReportStep(to: .reportComplete)
                }
                .frame(maxWidth: .infinity)
                .disabled(reportVM.reportReason.isEmpty)
                .opacity(reportVM.reportReason.isEmpty ? 0.4 : 1.0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(.background1)
        .onChange(of: selectedItems) { oldValue, newValue in
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
    
    private func removeImage(at index: Int) {
        selectedItems.remove(at: index)
        selectedImages.remove(at: index)
    }
}
