//
//  InterestEditView.swift
//  MeetKey
//
//  Created by sumin Kong on 2/6/26.
//

import SwiftUI

struct InterestEditView: View {
    @ObservedObject var viewModel: InterestEditViewModel
    let onSave: ([String]) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image(.arrowLeft2)
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            dismiss()
                        }
                    Spacer()
                    Text("관심사를 입력해주세요.")
                        .font(.meetKey(.title2))
                        .frame(height: 36)
                        .padding(.leading, )
                    Spacer()
                    Image(.arrowLeft2)
                        .frame(width: 24, height: 24)
                        .hidden()
                }
                .frame(height: 36)
                .padding(.top, 42)
                
                Text("전체 키워드 최소 3개 이상 선택해주세요.")
                    .font(.meetKey(.body5))
                    .foregroundColor(.text3)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 37)
                    .padding(.top, 13)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(viewModel.orderedInterests, id: \.category) { group in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(group.category)
                                    .font(.meetKey(.body4))
                                    .foregroundColor(.text3)
                                
                                FlowLayout(items: group.items) { item in
                                    InterestTagButton(
                                        text: item,
                                        isSelected: viewModel.selectedInterests.contains(item)
                                    ) {
                                        viewModel.toggleInterest(item)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 39)
                }
                Button {
                    // viewModel.result 저장 / 서버 호출 예정
                    guard viewModel.canSave else { return }
                    onSave(viewModel.result)
                    dismiss()
                } label: {
                    Text("저장")
                        .font(.meetKey(.title5))
                        .foregroundColor(.white01)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(viewModel.canSave ? Color.main : Color.disabled)
                        .cornerRadius(15)
                }
                .disabled(!viewModel.canSave)
                .padding(.bottom, 20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .navigationBarBackButtonHidden()
    }
}
