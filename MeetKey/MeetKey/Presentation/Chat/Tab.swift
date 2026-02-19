import Foundation

enum Tab: String, CaseIterable, Identifiable {
    case chat, people, home, folder, profile
    var id: String { rawValue }

    var iconAsset: String {
        switch self {
        case .chat: return "Chat"
        case .people: return "2 User"
        case .home: return "Home"
        case .folder: return "Folder"
        case .profile: return "myProfile"
        }
    }
}
