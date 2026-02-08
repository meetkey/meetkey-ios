import SwiftUI

// MARK: - Tab
enum Tab: String {
    case chat, people, home, folder, profile
}

// MARK: - Main View
struct ChatListView: View {

    private let pageBg = Color(.white)
    private let orange = Color("Orange")

    @State private var selectedTab: Tab = .chat
    @State private var chats: [ChatItem] = sampleChats

    var body: some View {
        NavigationStack {
            ZStack {
                pageBg.ignoresSafeArea()

                Group {
                    switch selectedTab {
                    case .chat:
                        chatListBody
                    case .people:
                        PlaceholderView(title: "People View")
                    case .home:
                        PlaceholderView(title: "Home View")
                    case .folder:
                        PlaceholderView(title: "Folder View")
                    case .profile:
                        PlaceholderView(title: "Profile View")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                BottomNavigationBar(selectedTab: $selectedTab)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var chatListBody: some View {
        VStack(spacing: 0) {
            ChatListHeader()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach($chats) { $chat in
                        ChatRow(chat: $chat, orange: orange)

                        Divider()
                            .padding(.leading, 90)
                            .opacity(0.3)
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Header
struct ChatListHeader: View {

    var body: some View {
        ZStack(alignment: .top) {

            Color(red: 0.93, green: 0.93, blue: 0.93)
                .opacity(0.9)
                .clipShape(BottomRoundedShape0(radius: 22))
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
                .ignoresSafeArea(edges: .top)

            HStack(spacing: 14) {

                Image("CheolSoo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Good Afternoon!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.22))

                    Text("김밋키")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }

                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.top, 15)
        }
        .frame(height: 90)
    }
}

// MARK: - Chat Row
struct ChatRow: View {

    @Binding var chat: ChatItem
    let orange: Color

    var body: some View {

        NavigationLink {
          
            if chat.name == "Jane Smith" {
                ChatRoomScreen(chat: $chat)
            } else {
                ChatDetailView(chat: $chat)
            }
        } label: {
            rowContent
        }
        .buttonStyle(.plain)
    }

    private var rowContent: some View {
        HStack(spacing: 14) {

            Image("Jane")
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {

                HStack(spacing: 6) {
                    if let badge = chat.badge {
                        Image(badge)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }

                    Text(chat.name)
                        .font(.system(size: 17, weight: .bold))

                    Text(chat.time)
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.5))

                    Spacer()
                }

                Text(chat.preview)
                    .font(.system(size: 15))
                    .foregroundColor(Color(white: 0.45))
                    .lineLimit(2)
            }

            if chat.unread > 0 {
                Text("\(chat.unread)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(orange)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// Chat Detail View (임시)
struct ChatDetailView: View {

    @Binding var chat: ChatItem

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Text("💬 \(chat.name)와의 대화방(임시)")
                .font(.system(size: 22, weight: .bold))

            Text("여기는 Jane이 아니라서 임시 화면")
                .foregroundColor(.gray)

            Spacer()
        }
        .navigationTitle(chat.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            // 뒤로 나올 때 읽음 처리
            if chat.unread > 0 { chat.unread = 0 }
        }
    }
}

// Bottom Navigation
struct BottomNavigationBar: View {

    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 22) {

            Button { selectedTab = .chat } label: {
                NavIcon(assetName: "Chat", selected: selectedTab == .chat)
            }
            Button { selectedTab = .people } label: {
                NavIcon(assetName: "2 User", selected: selectedTab == .people)
            }
            Button { selectedTab = .home } label: {
                NavIcon(assetName: "Home", selected: selectedTab == .home)
            }
            Button { selectedTab = .folder } label: {
                NavIcon(assetName: "Folder", selected: selectedTab == .folder)
            }
            Button { selectedTab = .profile } label: {
                NavIcon(assetName: "Profile", selected: selectedTab == .profile)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(red: 0.76, green: 0.76, blue: 0.76).opacity(0.2))
                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .buttonStyle(.plain)
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

struct PlaceholderView: View {
    let title: String
    var body: some View {
        VStack {
            Spacer()
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

struct ChatItem: Identifiable {
    let id: UUID
    let name: String
    let preview: String
    let time: String
    var unread: Int
    let badge: String?
}

// Sample Data
let sampleChats: [ChatItem] = [
    .init(id: UUID(), name: "Jane Smith", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "gold"),
    .init(id: UUID(), name: "Richard Thompson", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "silver"),
    .init(id: UUID(), name: "Sarah Williams", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "bronze"),
    .init(id: UUID(), name: "Michael Jones", preview: "Ciao! Let me know when you are free...", time: "3h", unread: 0, badge: "gold"),
    .init(id: UUID(), name: "Natalie Clark", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "silver"),
    .init(id: UUID(), name: "김유진", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "bronze")
]

struct BottomRoundedShape0: Shape {

    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = radius

        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - r))

        path.addArc(
            center: CGPoint(x: rect.width - r, y: rect.height - r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: r, y: rect.height))

        path.addArc(
            center: CGPoint(x: r, y: rect.height - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}

#Preview { ChatListView() }


