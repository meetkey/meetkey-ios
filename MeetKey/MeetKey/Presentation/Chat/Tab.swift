import Foundation

enum Tab: String, CaseIterable, Identifiable {
    case home, chat, profile
    var id: String { rawValue }

    var iconAsset: String {
        switch self {
        case .home: return "Home"
        case .chat: return "Chat"
        case .profile: return "Profile"
        }
    }
}
