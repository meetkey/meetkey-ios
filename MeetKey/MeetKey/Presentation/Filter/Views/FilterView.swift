import SwiftUI

protocol DisplayableFilter: Identifiable {
    var displayName: String { get }
}

// 기존 Enum들에 프로토콜 채택 (이미 displayName이 있으니 선언만 하면 됨)
extension SocialType: DisplayableFilter {}
extension MeetingType: DisplayableFilter {}
extension ChatType: DisplayableFilter {}
extension FriendType: DisplayableFilter {}
extension RelationType: DisplayableFilter {}

struct FilterView: View {
    @ObservedObject var homeVM: HomeViewModel
    @Environment(\.dismiss) var dismiss

    // 임시로 들고 있을 필터 (저장 버튼 누를 때만 적용하고 싶을 경우 대비)
    @State private var tempFilter: FilterModel

    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
        self._tempFilter = State(initialValue: homeVM.filter)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    InterestFilterSection(homeVM: homeVM,tempFilter: $tempFilter)

                    PersonalityFilterSection(tempFilter: $tempFilter)

                    LanguageFilterSection(tempFilter: $tempFilter)

                    AgeFilterSection(minAge: $tempFilter.minAge, maxAge: $tempFilter.maxAge)

                    DistanceFilterSection(maxDistance: $tempFilter.maxDistance)
                }
                .padding(.top, 13)
            }

            // 적용 버튼
            applyButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .navigationBarBackButtonHidden()
    }


    private var headerView: some View {
        HStack(spacing: 0) {
            Image(.arrowLeft2)
                .frame(width: 24, height: 24)
                .onTapGesture { dismiss() }
            Spacer()
            Text("필터")
                .font(.meetKey(.title2))
            Spacer()
            Image(.arrowLeft2).frame(width: 24, height: 24).hidden()
        }
        .frame(height: 36)
        .padding(.top, 42)
        .padding(.bottom, 20)
    }

    

 


  



    private var applyButton: some View {
        Button {
            homeVM.applyFilter(tempFilter)
            dismiss()
        } label: {
            Text("필터 적용하기")
                .font(.meetKey(.title5))
                .foregroundColor(.white01)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.main)
                .cornerRadius(15)
        }
        .padding(.bottom, 20)
    }

}
