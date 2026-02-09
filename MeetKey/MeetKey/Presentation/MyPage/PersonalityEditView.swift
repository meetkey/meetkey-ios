//
//  PersonalityEditView.swift
//  MeetKey
//
//  Created by sumin Kong on 2/6/26.
//

import SwiftUI

struct PersonalityEditView: View {
    @ObservedObject var viewModel: PersonalityEditViewModel
    let onSave: (Personalities) -> Void
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
                    ForEach(viewModel.personalityQuestions, id: \.question) { item in
                        PersonalityEditSection(
                            keyPath: item.keyPath,
                            question: item.question,
                            options: item.options,
                            viewModel: viewModel
                        )
                    }
                }
                .padding(.bottom, 40)
            }
            
            
            Button {
                guard viewModel.canSave else { return }
                let result = viewModel.toPersonalities()
                onSave(result)
                dismiss()
            } label: {
                Text("저장")
                    .font(.meetKey(.title5))
                    .foregroundColor(.white01)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(viewModel.canSave ? Color.main : Color.disabled)
                    .cornerRadius(15)
                    .onTapGesture {
                        dismiss()
                    }
            }
            .disabled(!viewModel.canSave)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .navigationBarBackButtonHidden()
    }
    
    
}

struct PersonalityEditSection: View {
    
    let keyPath: WritableKeyPath<Personalities, String>
    let question: String
    let options: [String]
    
    @ObservedObject var viewModel: PersonalityEditViewModel
    
    let columns = [
        GridItem(.fixed(112), spacing: 12),
        GridItem(.fixed(112), spacing: 12),
        GridItem(.fixed(112), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question)
                .font(.meetKey(.body4))
                .foregroundColor(.text3)
            
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(options, id: \.self) {
                    option in PersonalityOptionButton(
                        text: option,
                        isSelected: viewModel.selectedOptions[keyPath] == option
                    ) {
                        viewModel.selectOption(
                            keyPath: keyPath,
                            option: option
                        )
                    }
                }
            }
        }
    }
}


#Preview {
    PersonalityEditView(
        viewModel: PersonalityEditViewModel(),
        onSave: { result in
            print(result)
        }
    )
}
