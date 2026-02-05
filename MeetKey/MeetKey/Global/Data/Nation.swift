//
//  Nation.swift
//  MeetKey
//
//  Created by sumin Kong on 2/4/26.
//

import SwiftUI

enum Nation: String, CaseIterable, Codable {
    case spain
    case france
    case italy
    case japan
    case korea
    case china
    case germany
    case unitedStates

    // 국기 이미지
    var image: Image {
        switch self {
        case .spain:
            return Image(.esSpain)
        case .france:
            return Image(.frFrance)
        case .italy:
            return Image(.itItaly)
        case .japan:
            return Image(.jpJapan)
        case .korea:
            return Image(.krKoreaSouth)
        case .china:
            return Image(.cnChina)
        case .germany:
            return Image(.deGermany)
        case .unitedStates:
            return Image(.usUnitedStates)
        }
    }

    static func from(serverValue: String?) -> Nation? {
        guard let value = serverValue?.uppercased() else { return nil }

        switch value {
        case "KOREAN", "KOREA":
            return .korea
        case "ENGLISH", "USA", "US":
            return .unitedStates
        case "JAPANESE", "JAPAN":
            return .japan
        case "CHINESE", "CHINA":
            return .china
        case "GERMAN", "GERMANY":
            return .germany
        case "FRENCH", "FRANCE":
            return .france
        case "SPANISH", "SPAIN":
            return .spain
        case "ITALIAN", "ITALY":
            return .italy
        default:
            return nil
        }
    }
}
