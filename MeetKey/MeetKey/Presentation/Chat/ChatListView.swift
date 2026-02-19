import SwiftUI
import Foundation
import Combine

// MARK: - ViewModel (서버 연동 + mock fallback)
@MainActor
final class ChatListViewModel: ObservableObject {

    @Published var chats: [ChatItem] = sampleChats

    func load() async {
        do {
            let rooms = try await ChatService.shared.fetchChatRooms()
            let mapped = rooms.map { ChatItem.fromDTO($0) }
            self.chats = mapped.isEmpty ? sampleChats : mapped
        } catch {
            // 서버 에러/403/네트워크 실패 등 어떤 경우에도 UI는 mock 유지
            self.chats = sampleChats
            print("❌ fetchChatRooms failed:", error)
        }
    }
}

// MARK: - Main View
struct ChatListView: View {

    private let pageBg = Color(.white)
    private let orange = Color("Orange01") // 프로젝트 에셋명 맞춰두기

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
        .task { await vm.load() }
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

// MARK: - Header (기존 그대로)
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

// MARK: - Chat Row (서버/목업 UI 동일 유지 핵심)
struct ChatRow: View {

    @Binding var chat: ChatItem
    let orange: Color

    var body: some View {
        NavigationLink {
            if let roomId = chat.roomId, let opponent = chat.opponent {
                ChatRoomScreen(roomId: roomId, opponent: opponent)
            } else {
                // sample용 fallback
                ChatDetailView(chat: $chat)
            }
        } label: {
            rowContent
        }
        .buttonStyle(.plain)
    }

    private var rowContent: some View {
        HStack(spacing: 14) {

            // ✅ 프로필: 서버 URL이 있어도 "프레임 고정" + "동일한 둥근 마스크"로 UI 절대 안 깨짐
            ProfileAvatarView(
                urlString: chat.profileImageUrl,
                fallbackAssetName: "Jane"
            )
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 6) {

                HStack(spacing: 6) {

                    // ✅ badge는 서버에 없어도 자리 고정 (정렬/간격 동일)
                    Group {
                        if let badge = chat.badge, !badge.isEmpty {
                            Image(badge)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Color.clear
                        }
                    }
                    .frame(width: 18, height: 18)

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

// MARK: - Avatar View (UI 안 깨지게 프레임/placeholder 고정)
private struct ProfileAvatarView: View {
    let urlString: String?
    let fallbackAssetName: String

    var body: some View {
        ZStack {
            // ✅ 항상 동일한 뒷배경 (로딩/실패/성공 상관없이 레이아웃 고정)
            Circle()
                .fill(Color(white: 0.92))

            if let urlString,
               let url = URL(string: urlString),
               !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        // ✅ 로딩/실패 시에도 mock과 동일한 기본 이미지로 통일
                        Image(fallbackAssetName)
                            .resizable()
                            .scaledToFill()
                    }
                }
            } else {
                Image(fallbackAssetName)
                    .resizable()
                    .scaledToFill()
            }
        }
        .clipShape(Circle())
    }
}

// MARK: - Chat Detail (샘플용)
struct ChatDetailView: View {

    @Binding var chat: ChatItem

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Text("💬 \(chat.name)와의 대화방(임시)")
                .font(.system(size: 22, weight: .bold))

            Text("여기는 샘플용 임시 화면")
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

// MARK: - UI Model (서버 데이터가 와도 mock 느낌 유지하도록 정규화)
struct ChatItem: Identifiable {
    let id: Int

    let name: String
    let preview: String
    let time: String
    var unread: Int
    let badge: String?

    // 서버 연동
    let roomId: Int?
    let opponent: ChatOpponentDTO?
    let profileImageUrl: String?

    static func fromDTO(_ dto: ChatRoomSummaryDTO) -> ChatItem {
        let normalizedPreview: String = {
            let raw = (dto.lastChatMessages ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return raw.isEmpty ? "Ciao! Let me know when you ar..." : raw
        }()

        let normalizedTime = relativeTime(dto.updatedAt)

        let unread = dto.unReadMessageCnt ?? dto.unreadCount

        // ✅ badge는 서버에 없어도 mock처럼 항상 보이게 하고 싶으면 안정적으로 부여
        // (원치 않으면 nil로 두고, 위에서 자리만 유지해도 UI는 안 깨짐)
        let badge = stableBadge(userId: dto.chatOpponent.userId)

        return .init(
            id: dto.roomId,
            name: dto.chatOpponent.nickname,
            preview: normalizedPreview,
            time: normalizedTime,
            unread: unread,
            badge: badge,
            roomId: dto.roomId,
            opponent: dto.chatOpponent,
            profileImageUrl: dto.chatOpponent.profileImageUrl
        )
    }

    private static func stableBadge(userId: Int) -> String {
        switch abs(userId) % 3 {
        case 0: return "gold"
        case 1: return "silver"
        default: return "bronze"
        }
    }

    private static func relativeTime(_ isoString: String) -> String {
        guard let date = parseISO8601(isoString) else { return "now" }
        let diff = Int(Date().timeIntervalSince(date))
        if diff <= 0 { return "now" }

        let m = diff / 60
        let h = diff / 3600
        let d = diff / 86400

        if d > 0 { return "\(d)d" }
        if h > 0 { return "\(h)h" }
        if m > 0 { return "\(m)m" }
        return "now"
    }

    private static func parseISO8601(_ s: String) -> Date? {
        let f1 = ISO8601DateFormatter()
        f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f1.date(from: s) { return d }

        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        return f2.date(from: s)
    }
}

// MARK: - Sample Data (mock 유지)
let sampleChats: [ChatItem] = [
    .init(id: -1, name: "Jane Smith", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "gold", roomId: nil, opponent: nil, profileImageUrl: nil),
    .init(id: -2, name: "Richard Thompson", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "silver", roomId: nil, opponent: nil, profileImageUrl: nil),
    .init(id: -3, name: "Sarah Williams", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "bronze", roomId: nil, opponent: nil, profileImageUrl: nil),
    .init(id: -4, name: "Michael Jones", preview: "Ciao! Let me know when you are free...", time: "3h", unread: 0, badge: "gold", roomId: nil, opponent: nil, profileImageUrl: nil),
    .init(id: -5, name: "Natalie Clark", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "silver", roomId: nil, opponent: nil, profileImageUrl: nil),
    .init(id: -6, name: "김유진", preview: "Ciao! Let me know when you ar...", time: "3h", unread: 12, badge: "bronze", roomId: nil, opponent: nil, profileImageUrl: nil)
]

// MARK: - Shapes
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
