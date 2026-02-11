//
//  InterestFilterSection.swift
//  MeetKey
//
//  Created by 전효빈 on 2/11/26.
//

import SwiftUI

struct InterestFilterSection: View {
    @ObservedObject var homeVM: HomeViewModel
    @Binding var tempFilter: FilterModel 
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            ForEach(homeVM.groupedInterests) { group in
                VStack(alignment: .leading, spacing: 12) {
                    Text(group.category)
                        .font(.meetKey(.body4))
                        .foregroundColor(.text3)
                    
                    TagFlowLayout(spacing: 8) {
                        ForEach(group.items) { item in
                            InterestTagButton(
                                text: item.displayName,
                                isSelected: tempFilter.interests?.contains(item.displayName) ?? false
                            ) {
                                toggleInterest(item.displayName)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func toggleInterest(_ name: String) {
        if var list = tempFilter.interests {
            if list.contains(name) { list.removeAll { $0 == name } }
            else { list.append(name) }
            tempFilter.interests = list
        } else {
            tempFilter.interests = [name]
        }
    }
}
