import SwiftUI

protocol DisplayableFilter: Identifiable {
    var displayName: String { get }
}

extension SocialType: DisplayableFilter {}
extension MeetingType: DisplayableFilter {}
extension ChatType: DisplayableFilter {}
extension FriendType: DisplayableFilter {}
extension RelationType: DisplayableFilter {}

struct FilterView: View {
    @ObservedObject var homeVM: HomeViewModel
    @Environment(\.dismiss) var dismiss

    @State private var tempFilter: FilterModel

    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
        self._tempFilter = State(initialValue: homeVM.filter)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    InterestFilterSection(homeVM: homeVM, tempFilter: $tempFilter)

                    PersonalityFilterSection(tempFilter: $tempFilter)

                    LanguageFilterSection(tempFilter: $tempFilter)

                    AgeFilterSection(minAge: $tempFilter.minAge, maxAge: $tempFilter.maxAge)

                    DistanceFilterSection(maxDistance: $tempFilter.maxDistance)
                }
                .padding(.top, 13)
            }
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden()
        .background(Color.background1)
    }

    private var headerView: some View {
        HStack(spacing: 0) {
            Button(action: { dismiss() }) {
                Text("취소")
                    .font(.meetKey(.body2))
                    .foregroundStyle(Color.text2)
            }
            
            Spacer()
            
            Text("필터")
                .font(.meetKey(.title5))
                .foregroundStyle(Color.text1)
            
            Spacer()
            
            Button(action: {
                homeVM.applyFilter(tempFilter)
                dismiss()
            }) {
                Text("적용")
                    .font(.meetKey(.body1))
                    .foregroundStyle(Color.main)
            }
        }
        .frame(height: 36)
        .padding(.bottom, 20)
    }
}
