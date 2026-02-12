//
//  PersonalityEditView.swift
//  MeetKey
//
//  Created by sumin Kong on 2/6/26.
//

import SwiftUI

struct PersonalityEditView: View {
    
    @StateObject var viewModel: PersonalityEditViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(.arrowLeft2)
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        dismiss()
                    }
                Spacer()
                Text("나는 어떤 성향인가요?")
                    .font(.meetKey(.title2))
                    .frame(height: 36)
                Spacer()
                Image(.arrowLeft2)
                    .frame(width: 24, height: 24)
                    .hidden()
            }
            .frame(height: 36)
            .padding(.top, 42)
            
            Text("각 카테고리 별로 한 개씩 선택해주세요.")
                .font(.meetKey(.body5))
                .foregroundColor(.text3)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 37)
                .padding(.top, 13)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(viewModel.personalityOptions, id: \.title) { category in
                        PersonalityEditSection(
                            category: category,
                            viewModel: viewModel
                        )
                    }
                }
                .padding(.bottom, 40)
            }
            
            
            Button {
                guard viewModel.canSave else { return }
                viewModel.savePersonalities { success in
                    if success {
                        dismiss()
                    } else {
                        print("⚠️ 성향 저장 실패")
                    }
                }
            } label: {
                Text("저장")
                    .font(.meetKey(.title5))
                    .foregroundColor(.white01)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(viewModel.canSave ? Color.main : Color.disabled)
                    .cornerRadius(15)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.getPersonalities()
        }
    }
    
    
}

struct PersonalityEditSection: View {
    let category: PersonalitiesDTO
    @ObservedObject var viewModel: PersonalityEditViewModel
    
    let columns = [
        GridItem(.fixed(112), spacing: 12),
        GridItem(.fixed(112), spacing: 12),
        GridItem(.fixed(112), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.title)
                .font(.meetKey(.body4))
                .foregroundColor(.text3)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(category.options, id: \.self) {option in
                    let key = PersonalityKeyMapper.key(for: category.title) ?? ""
                    let isSelected = viewModel.selectedOptions[key] == option
                    PersonalityOptionButton(
                        text: PersonalityOptionMapper.label(for: key, option: option),
                        isSelected: isSelected
                    ) {
                        viewModel.selectOption(
                            title: category.title,
                            option: option
                        )
                    }
                }
            }
        }
    }
}
