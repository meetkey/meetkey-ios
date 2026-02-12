//
//  ReportType.swift
//  MeetKey
//
//  Created by 전효빈 on 2/12/26.
//

import Foundation

enum ReportType: String, CaseIterable, Codable {
    case inappropriate = "INAPPROPRIATE"    // 부적절함
    case urgent = "URGENT"                  // 긴급함
    case ineligible = "INELIGIBLE"          // 부적격
    case sexualContent = "SEXUAL_CONTENT"   // 성적인 콘텐츠
    case hateSpeech = "HATE_SPEECH"         // 혐오 발언
    case other = "OTHER"                    // 기타

    var displayName: String {
        switch self {
        case .inappropriate: return "부적절한 프로필"
        case .urgent: return "긴급한 도움이 필요함"
        case .ineligible: return "부적격 사용자"
        case .sexualContent: return "성적인 콘텐츠"
        case .hateSpeech: return "혐오 표현"
        case .other: return "기타 사유"
        }
    }
}
