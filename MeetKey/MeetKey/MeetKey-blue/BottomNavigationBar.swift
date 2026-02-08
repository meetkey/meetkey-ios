import SwiftUI

struct BottomNavigationBar: View {
    @Binding var selectedTab: Tab

    private let tabs: [Tab] = Tab.allCases

    var body: some View {
        HStack(spacing: 22) {
            ForEach(tabs) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    NavIcon(assetName: tab.iconAsset, selected: selectedTab == tab)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(navBackground)
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    private var navBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color(red: 0.76, green: 0.76, blue: 0.76).opacity(0.2))
            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
    }
}

struct NavIcon: View {
    let assetName: String
    var selected: Bool = false

    var body: some View {
        Image(assetName)
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: 22, height: 22)
            .foregroundColor(selected ? .white : .gray)
            .frame(width: 44, height: 44)
            .background(Circle().fill(selected ? Color.black : Color.clear))
    }
}

#Preview {
    struct PreviewHost: View {
        @State var tab: Tab = .chat
        var body: some View {
            BottomNavigationBar(selectedTab: $tab)
                .padding()
                .background(Color.white)
        }
    }
    return PreviewHost()
}
