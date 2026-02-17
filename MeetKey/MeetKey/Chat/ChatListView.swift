import SwiftUI
import Combine

// ViewModel (서버 연동 + 403 fallback)
@MainActor
final class ChatListViewModel: ObservableObject {

    @Published var chats: [ChatItem] = sampleChats

    func load() async {
        do {
            let rooms: [ChatRoomSummaryDTO] = try await fetchChatRooms()
            let mapped = rooms.map { ChatItem.fromDTO($0) }
            self.chats = mapped.isEmpty ? sampleChats : mapped
        } catch {
            // 어떤 에러(403 포함)도 UI는 더미로 유지
            self.chats = sampleChats
            print("❌ fetchChatRooms failed:", error)
        }
    }

    // NetworkProvider 콜백 -> async/await 브릿지
    private func fetchChatRooms() async throws -> [ChatRoomSummaryDTO] {
        try await withCheckedThrowingContinuation { cont in
            NetworkProvider.shared.requestChat(.fetchChatRooms, type: [ChatRoomSummaryDTO].self) { result in
                switch result {
                case .success(let rooms):
                    cont.resume(returning: rooms)
                case .failure(let error):
                    cont.resume(throwing: error)
                }
            }
        }
    }
}

// Main View
struct ChatListView: View {

    private let pageBg = Color(.white)
    private let orange = Color("Orange")

    @State private var selectedTab: Tab = .chat
    @StateObject private var vm = ChatListViewModel()

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
        .task {
            await vm.load()
        }
    }

    private var chatListBody: some View {
        VStack(spacing: 0) {
            ChatListHeader()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach($vm.chats) { $chat in
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

// MARK: - Chat Row (UI 그대로, 단 네비게이션만 안전하게)
struct ChatRow: View {

    @Binding var chat: ChatItem
    let orange: Color

    var body: some View {

        NavigationLink {
            // ✅ 서버 연동으로 들어온 데이터면 roomId/opponent로 진짜 채팅방 진입
            if let roomId = chat.roomId, let opponent = chat.opponent {
                ChatRoomScreen(roomId: roomId, opponent: opponent)
            } else {
                // ✅ 더미 데이터면 기존 로직 유지
                if chat.name == "Jane Smith" {
                    // 더미 Jane은 roomId 2로 고정해서 들어가게(원하면 바꿔)
                    ChatRoomScreen(roomId: 2, opponent: .init(userId: 0, nickname: chat.name, profileImageUrl: nil))
                } else {
                    ChatDetailView(chat: $chat)
                }
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

// Chat Detail View (UI 그대로)
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
            if chat.unread > 0 { chat.unread = 0 }
        }
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

// MARK: - UI Model (roomId/opponent만 추가: UI엔 영향 없음)
struct ChatItem: Identifiable {
    let id: UUID
    let name: String
    let preview: String
    let time: String
    var unread: Int
    let badge: String?

    // ✅ 서버 연동용(추가해도 UI 레이아웃 안 바뀜)
    let roomId: Int?
    let opponent: ChatOpponentDTO?

    static func fromDTO(_ dto: ChatRoomSummaryDTO) -> ChatItem {
        .init(
            id: UUID(),
            name: dto.chatOpponent.nickname,
            preview: (dto.lastChatMessages ?? "").unquoted, // ChatModels.swift extension 사용
            time: dto.updatedAt, // 원하면 “3h” 같은 상대시간으로 바꿔도 됨 (UI는 그대로)
            unread: dto.unReadMessageCnt ?? dto.unreadCount,
            badge: nil,
            roomId: dto.roomId,
            opponent: dto.chatOpponent
        )
    }
}

// Sample Data (그대로)
let sampleChats: [ChatItem] = [
    .init(id: UUID(), name: "Jane Smith", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "gold", roomId: nil, opponent: nil),
    .init(id: UUID(), name: "Richard Thompson", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "silver", roomId: nil, opponent: nil),
    .init(id: UUID(), name: "Sarah Williams", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "bronze", roomId: nil, opponent: nil),
    .init(id: UUID(), name: "Michael Jones", preview: "Ciao! Let me know when you are free...", time: "3h", unread: 0, badge: "gold", roomId: nil, opponent: nil),
    .init(id: UUID(), name: "Natalie Clark", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "silver", roomId: nil, opponent: nil),
    .init(id: UUID(), name: "김유진", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "bronze", roomId: nil, opponent: nil)
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

