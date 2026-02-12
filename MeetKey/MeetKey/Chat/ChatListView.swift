import SwiftUI
import Combine

// DTO helpers
extension ChatRoomSummaryDTO: Identifiable {
    var id: Int { roomId }
}

// ViewModel
@MainActor
final class ChatListViewModel: ObservableObject {

    @Published var rooms: [ChatRoomSummaryDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            rooms = try await ChatService.shared.fetchChatRooms()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func refresh() async { await load() }
}

// MARK: - Main View
struct ChatListView: View {

    private let pageBg = Color(.white)
    private let orange = Color("Orange01")

    @StateObject private var viewModel = ChatListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                pageBg.ignoresSafeArea()
                chatListBody
            }
            .toolbar(.hidden, for: .navigationBar)
            .task { await viewModel.load() }
        }
    }

    private var chatListBody: some View {
        VStack(spacing: 0) {

            ChatListHeader()

            if viewModel.isLoading && viewModel.rooms.isEmpty {
                ProgressView().padding(.top, 24)
                Spacer()
            } else if let msg = viewModel.errorMessage, viewModel.rooms.isEmpty {
                VStack(spacing: 12) {
                    Text("채팅 목록을 불러오지 못했어요.")
                        .font(.system(size: 16, weight: .semibold))

                    Text(msg)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("다시 시도") { Task { await viewModel.load() } }
                        .buttonStyle(.borderedProminent)
                }
                .padding(.top, 24)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.rooms) { room in
                            NavigationLink {
                                ChatRoomScreen(roomId: room.roomId, opponent: room.chatOpponent)
                            } label: {
                                ChatRoomRow(room: room, orange: orange)
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .padding(.leading, 90)
                                .opacity(0.3)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                }
                .refreshable { await viewModel.refresh() }
            }
        }
    }
}

// MARK: - Header
struct ChatListHeader: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Chat")
                    .font(.system(size: 28, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 12)

            Divider().opacity(0.1)
        }
        .background(Color.white)
    }
}

// MARK: - Row
struct ChatRoomRow: View {

    let room: ChatRoomSummaryDTO
    let orange: Color

    var body: some View {
        HStack(spacing: 14) {

            ProfileCircle(
                imageURL: room.chatOpponent.profileImageUrl,
                fallbackText: room.chatOpponent.nickname
            )
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 6) {

                HStack(spacing: 8) {
                    Text(room.chatOpponent.nickname)
                        .font(.system(size: 17, weight: .bold))
                        .lineLimit(1)

                    Spacer()

                    Text(DateFormatters.relativeTime(fromISO: room.updatedAt))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                HStack(alignment: .top, spacing: 10) {
                    Text((room.lastChatMessages ?? " ").unquoted)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Spacer()

                    if room.unreadCount > 0 {
                        Text("\(room.unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(orange)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Small UI pieces
struct ProfileCircle: View {
    let imageURL: String?
    let fallbackText: String

    var body: some View {
        ZStack {
            Circle().fill(Color(.systemGray5))

            if let urlStr = imageURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let image): image.resizable().scaledToFill()
                    case .failure: InitialsView(text: fallbackText)
                    @unknown default: InitialsView(text: fallbackText)
                    }
                }
                .clipShape(Circle())
            } else {
                InitialsView(text: fallbackText)
            }
        }
        .clipped()
    }
}

struct InitialsView: View {
    let text: String

    var initials: String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "?" }
        return String(Array(trimmed).prefix(2))
    }

    var body: some View {
        Text(initials)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.secondary)
    }
}

// MARK: - Date formatting
enum DateFormatters {
    static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static func relativeTime(fromISO isoString: String) -> String {
        if let date = iso.date(from: isoString) {
            return relativeTime(from: date)
        }
        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        if let date = f2.date(from: isoString) {
            return relativeTime(from: date)
        }
        return ""
    }

    static func relativeTime(from date: Date) -> String {
        let diff = Int(Date().timeIntervalSince(date))
        if diff < 60 { return "방금" }
        let minutes = diff / 60
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h" }
        let days = hours / 24
        return "\(days)d"
    }

    static func chatTime(from date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    static func chatTime(fromISO isoString: String) -> String {
        if let date = iso.date(from: isoString) {
            return chatTime(from: date)
        }
        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        if let date = f2.date(from: isoString) {
            return chatTime(from: date)
        }
        return ""
    }
}

#Preview { ChatListView() }
