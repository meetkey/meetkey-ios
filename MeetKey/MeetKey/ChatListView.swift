import SwiftUI

struct ChatPreview: Identifiable, Equatable {
    let id: UUID
    let name: String
    let subtitle: String
    let time: String
    var unreadCount: Int
    let avatarSystemImage: String
    let hasAvatar: Bool

    init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        time: String,
        unreadCount: Int,
        avatarSystemImage: String,
        hasAvatar: Bool
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.time = time
        self.unreadCount = unreadCount
        self.avatarSystemImage = avatarSystemImage
        self.hasAvatar = hasAvatar
    }
}

struct ChatListView: View {
    @State private var selectedTab: BottomTab = .chat
    @State private var chats: [ChatPreview] = [
        .init(name: "July",  subtitle: "Ciao! Let me know when you are fr...", time: "3h", unreadCount: 2, avatarSystemImage: "person.crop.circle.fill", hasAvatar: true),
        .init(name: "Marco", subtitle: "hi!",                               time: "3h", unreadCount: 0, avatarSystemImage: "person.crop.circle.fill", hasAvatar: true),
        .init(name: "John",  subtitle: "Let me know",                        time: "3h", unreadCount: 1, avatarSystemImage: "person.crop.circle.fill", hasAvatar: true),
        .init(name: "Jessy", subtitle: "when you are free?",                 time: "3h", unreadCount: 0, avatarSystemImage: "person.crop.circle.fill", hasAvatar: true),
        .init(name: "Anna",  subtitle: "Ciao! Let me know when you are fr...", time: "3h", unreadCount: 0, avatarSystemImage: "person.crop.circle.fill", hasAvatar: true)
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(chats.indices, id: \.self) { index in
                                NavigationLink {
                                    ChatRoomView(userName: chats[index].name)
                                } label: {
                                    VStack(spacing: 0) {
                                        ChatRow(chat: chats[index])
                                        Divider()
                                    }
                                }
                                .buttonStyle(.plain)
                                .simultaneousGesture(TapGesture().onEnded {
                                    chats[index].unreadCount = 0
                                })
                            }
                        }
                    }

                    BottomNavBar(selected: $selectedTab)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(spacing: 0) {
            HStack {
                Text("채팅")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()
        }
        .background(Color.white)
    }
}

struct ChatRow: View {
    let chat: ChatPreview

    var body: some View {
        HStack(spacing: 14) {
            avatar

            VStack(alignment: .leading, spacing: 6) {
                Text(chat.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)

                Text(chat.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(chat.time)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                if chat.unreadCount > 0 {
                    UnreadBadge(count: chat.unreadCount)
                } else {
                    Color.clear.frame(width: 22, height: 18)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.white)
    }

    private var avatar: some View {
        ZStack(alignment: .bottomTrailing) {
            if chat.hasAvatar {
                Image(systemName: chat.avatarSystemImage)
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(Color(white: 0.85))
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(white: 0.92))
                    .frame(width: 64, height: 64)
            }

            StatusBadge(iconName: "Icon-51")
                .offset(x: 4, y: 4)
        }
    }
}

struct StatusBadge: View {
    let iconName: String

    private let badgeSize: CGFloat = 22
    private let ringSize: CGFloat = 26
    private let iconSize: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: ringSize, height: ringSize)

            Circle()
                .fill(Color("Orange"))
                .frame(width: badgeSize, height: badgeSize)

            Image(iconName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundColor(.white)
        }
    }
}

struct UnreadBadge: View {
    let count: Int

    var body: some View {
        Text("\(count)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color("Orange")))
            .frame(minWidth: 22)
    }
}

enum BottomTab: String, CaseIterable {
    case chat = "채팅"
    case content = "콘텐츠"
    case home = "홈"
    case meet = "만남"
    case profile = "프로필"
}

struct BottomNavBar: View {
    @Binding var selected: BottomTab

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                ForEach(BottomTab.allCases, id: \.self) { tab in
                    Spacer()
                    BottomNavItem(title: tab.rawValue, isSelected: selected == tab)
                        .onTapGesture { selected = tab }
                    Spacer()
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 22)
            .background(Color.white)
        }
    }
}

struct BottomNavItem: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(isSelected ? .black : Color(white: 0.45))
            .frame(width: 56, height: 56)
            .background(
                Circle()
                    .fill(isSelected ? Color(white: 0.92) : Color.clear)
            )
    }
}

struct ChatRoomView: View {
    let userName: String

    var body: some View {
        VStack(spacing: 12) {
            Text("\(userName) 채팅방")
                .font(.title2.bold())
            Text("아직 채팅 화면 구현 전")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationTitle(userName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ChatListView()
}

