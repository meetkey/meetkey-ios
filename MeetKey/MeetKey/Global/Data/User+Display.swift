//
//  User+Display.swift
//  MeetKey
//
//  Created by 전효빈 on 2/12/26.
//

import Foundation

extension User {
    var genderDisplayName: String {
        guard let gender = gender?.uppercased() else { return "미설정" }
        switch gender {
        case "MALE": return "남성"
        case "FEMALE": return "여성"
        default: return gender
        }
    }

    var levelDisplayName: String {
        LanguageLevelType(rawValue: level.uppercased())?.displayName ?? level
    }

    var nativeLanguageDisplayName: String {
        LanguageType(rawValue: first.uppercased())?.displayName ?? first
    }
    
    var targetLanguageDisplayName: String {
        LanguageType(rawValue: target.uppercased())?.displayName ?? target
    }

    var socialDisplayName: String {
        guard let raw = personalities?.socialType.uppercased() else { return "정보 없음" }
        return SocialType(rawValue: raw)?.displayName ?? raw
    }

    var meetingDisplayName: String {
        guard let raw = personalities?.meetingType.uppercased() else { return "정보 없음" }
        return MeetingType(rawValue: raw)?.displayName ?? raw
    }

    var chatDisplayName: String {
        guard let raw = personalities?.chatType.uppercased() else { return "정보 없음" }
        return ChatType(rawValue: raw)?.displayName ?? raw
    }

    var friendDisplayName: String {
        guard let raw = personalities?.friendType.uppercased() else { return "정보 없음" }
        return FriendType(rawValue: raw)?.displayName ?? raw
    }

    var relationDisplayName: String {
        guard let raw = personalities?.relationType.uppercased() else { return "정보 없음" }
        return RelationType(rawValue: raw)?.displayName ?? raw
    }

    var interestsDisplayNames: [String] {
        guard let list = interests else { return [] }
        return list.compactMap { raw in
            InterestType(rawValue: raw.uppercased())?.displayName ?? raw
        }
    }
}
