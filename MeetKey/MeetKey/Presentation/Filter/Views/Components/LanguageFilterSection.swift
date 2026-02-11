

import SwiftUI

struct LanguageFilterSection: View {
    @Binding var tempFilter: FilterModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // 국적
            VStack(alignment: .leading, spacing: 12) {
                Text("국적").font(.meetKey(.body4)).foregroundColor(.text3)
                TagFlowLayout(spacing: 8) {
                    ForEach(NationalityType.allCases) { nation in
                        InterestTagButton(text: nation.displayName, isSelected: tempFilter.hometown == nation.displayName) {
                            tempFilter.hometown = (tempFilter.hometown == nation.displayName) ? nil : nation.displayName
                        }
                    }
                }
            }
            
            // 모국어
            VStack(alignment: .leading, spacing: 12) {
                Text("사용 언어 (모국어)").font(.meetKey(.body4)).foregroundColor(.text3)
                TagFlowLayout(spacing: 8) {
                    ForEach(LanguageType.allCases) { language in
                        InterestTagButton(text: language.displayName, isSelected: tempFilter.nativeLanguage == language.displayName) {
                            tempFilter.nativeLanguage = (tempFilter.nativeLanguage == language.displayName) ? nil : language.displayName
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("관심 언어 (학습 중)")
                    .font(.meetKey(.body4))
                    .foregroundColor(.text3)
                
                TagFlowLayout(spacing: 8) {
                    ForEach(LanguageType.allCases) { language in
                        InterestTagButton(
                            text: language.displayName,
                            isSelected: tempFilter.targetLanguage == language.displayName
                        ) {
                            tempFilter.targetLanguage = (tempFilter.targetLanguage == language.displayName) ? nil : language.displayName
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("언어 실력")
                    .font(.meetKey(.body4))
                    .foregroundColor(.text3)
                
                TagFlowLayout(spacing: 8) {
                    ForEach(LanguageLevelType.allCases) { level in
                        InterestTagButton(
                            text: level.displayName,
                            isSelected: tempFilter.targetLanguageLevel == level.rawValue
                        ) {
                            if tempFilter.targetLanguageLevel == level.rawValue {
                                tempFilter.targetLanguageLevel = nil
                            } else {
                                tempFilter.targetLanguageLevel = level.rawValue
                            }
                        }
                    }
                }
            }
        }
    }
}
