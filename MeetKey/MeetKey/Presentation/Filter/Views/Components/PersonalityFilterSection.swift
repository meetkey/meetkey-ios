

import SwiftUI

struct PersonalityFilterSection: View {
    @Binding var tempFilter: FilterModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            filterGroup(title: "소셜 성향", items: SocialType.allCases, selected: tempFilter.social) { tempFilter.social = $0 }
            filterGroup(title: "대화 인원", items: MeetingType.allCases, selected: tempFilter.meeting) { tempFilter.meeting = $0 }
            filterGroup(title: "대화 주도", items: ChatType.allCases, selected: tempFilter.chat) { tempFilter.chat = $0 }
            filterGroup(title: "친구 타입", items: FriendType.allCases, selected: tempFilter.friend) { tempFilter.friend = $0 }
            filterGroup(title: "관계 목적", items: RelationType.allCases, selected: tempFilter.relation) { tempFilter.relation = $0 }
        }
    }
    
    private func filterGroup<T: DisplayableFilter & Equatable>(
        title: String,
        items: [T],
        selected: T?,
        onTap: @escaping (T) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.meetKey(.body4))
                .foregroundColor(.text3)
            
            TagFlowLayout(spacing: 8) {
                ForEach(items) { item in
                    InterestTagButton(
                        text: item.displayName,
                        isSelected: selected == item
                    ) {
                        onTap(item)
                    }
                }
            }
        }
    }
}
