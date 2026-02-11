//
//  FilterModel.swift
//  MeetKey
//
//  Created by 전효빈 on 2/10/26.
//

import Foundation
import SwiftUI

struct FilterModel:Equatable {
    
    var social : SocialType?
    var meeting : MeetingType?
    var chat : ChatType?
    var friend : FriendType?
    var relation : RelationType?
    
    var combinedPersonalities: [String]? {
        let list = [
            social?.rawValue,
            meeting?.rawValue,
            chat?.rawValue,
            friend?.rawValue,
            relation?.rawValue
        ].compactMap { $0 }
        
        return list.isEmpty ? nil : list
    }
    

    var maxDistance: Double?
    var minAge : Int? = 18
    var maxAge : Int? = 50
    var interests: [String]?
    var hometown: String?
    var nativeLanguage: String?
    var targetLanguage: String?
    var targetLanguageLevel: String?
    var personality: [String]?
}


enum SocialType: String, CaseIterable, Identifiable {
    case extrovert = "EXTROVERT"
    case introvert = "INTROVERT"
    case occasional = "OCCASIONAL"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .extrovert: return "외향적"
        case .introvert: return "내향적"
        case .occasional: return "상관없음"
        }
    }
}

enum MeetingType: String, CaseIterable, Identifiable {
    case group = "GROUP"
    case one = "ONE"
    case any = "ANY"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .group: return "다인 대화"
        case .one: return "1:1 대화"
        case .any: return "상관없음"
        }
    }
}

enum ChatType: String, CaseIterable, Identifiable {
    case initiator = "INITIATOR"
    case responder = "RESPONDER"
    case balanced = "BALANCED"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .initiator: return "먼저 대화"
        case .responder: return "상대방 주도 대화"
        case .balanced: return "상관없음"
        }
    }
}

enum FriendType: String, CaseIterable, Identifiable {
    case sameGender = "SAME_GENDER"
    case oppositeGender = "OPPOSITE_GENDER"
    case any = "ANY"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .sameGender: return "동성"
        case .oppositeGender: return "이성"
        case .any: return "모두"
        }
    }
}

enum RelationType: String, CaseIterable, Identifiable {
    case casual = "CASUAL"
    case leading = "LEADING"
    case cultureExchange = "CULTURE_EXCHANGE"
    case offlineMeetUP = "OFFLINE_MEET_UP"
    case friendship = "FRIENDSHIP"
    case travelGUide = "TRAVEL_GUIDE"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .casual: return "가벼운 대화"
        case .leading: return "언어 학습"
        case .cultureExchange: return "문화 교류"
        case .offlineMeetUP: return "오프라인 교류"
        case .friendship: return "지속적 연락"
        case .travelGUide: return "여행 가이드"
        }
    }
}

enum InterestType: String, CaseIterable, Identifiable {
    case travel = "TRAVEL"
    case cafe = "CAFE"
    case restaurant = "RESTAURANT"
    case walk = "WALK"
    case pet = "PET"
    case vlog = "VLOG"
    case knit = "KNIT"
    case photo = "PHOTO"
    case life = "LIFE"
    case develop = "DEVELOP"
    //일상 라이프스타일
    case movie = "MOVIE"
    case drama = "DRAMA"
    case music = "MUSIC"
    case kpop = "KPOP"
    case pop = "POP"
    case netflix = "NETFLIX"
    case youtube = "YOUTUBE"
    case webtoon = "WEBTOON"
    case animation = "ANIMATION"
    case game = "GAME"
    case book = "BOOK"
    //문화 콘텐츠
    case language = "LANGUAGE"
    case stock = "STOCK"
    case investment = "INVESTMENT"
    case news = "NEWS"
    case socialIssues = "SOCIALISSUES"
    case tech = "TECH"
    case business = "BUSINESS"
    case design = "DESIGN"
    case marketing = "MARKETING"
    case career = "CAREER"
    case job = "JOB"
    //지식 시사
    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .travel: return "여행"
        case .cafe: return "카페 탐방"
        case .restaurant: return "맛집 찾기"
        case .walk: return "산책"
        case .pet: return "반려동물"
        case .vlog: return "일상 브이로그"
        case .knit: return "뜨개질"
        case .photo: return "사진찍기"
        case .life: return "미니멀 라이프"
        case .develop: return "자기계발"
        case .movie: return "영화"
        case .drama: return "드라마"
        case .music: return "음악"
        case .kpop: return "K-POP"
        case .pop: return "해외 팝송"
        case .netflix: return "넷플릭스"
        case .youtube: return "유튜브"
        case .webtoon: return "웹툰/만화"
        case .animation: return "애니메이션"
        case .game: return "게임"
        case .book: return "책"
        case .language: return "언어 공부"
        case .stock: return "주식"
        case .investment: return "투자"
        case .news: return "뉴스"
        case .socialIssues: return "사회 이슈"
        case .tech: return "테크/IT"
        case .business: return "비즈니스"
        case .design: return "디자인"
        case .marketing: return "마케팅"
        case .career: return "커리어"
        case .job: return "취업"
        }
    }
}

enum NationalityType: String, CaseIterable, Identifiable {
    case southKorea = "SOUTH_KOREA"
    case usa = "USA"
    case japan = "JAPAN"
    case germany = "GERMANY"
    case italy = "ITALY"
    case uk = "UK"
    case france = "FRANCE"
    case spain = "SPAIN"
    case china = "CHINA"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .southKorea: return "South Korea"
        case .usa: return "USA"
        case .japan: return "Japan"
        case .germany: return "Germany"
        case .italy: return "Italy"
        case .uk: return "UK"
        case .france: return "France"
        case .spain: return "Spain"
        case .china: return "China"
        }
    }
}

enum LanguageType: String, CaseIterable, Identifiable {
    case korean = "KOREAN"
    case english = "ENGLISH"
    case japanese = "JAPANESE"
    case chinese = "CHINESE"
    case spanish = "SPANISH"
    case german = "GERMAN"
    case french = "FRENCH"
    case italian = "ITALIAN"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .korean: return "한국어"
        case .english: return "영어"
        case .japanese: return "일본어"
        case .chinese: return "중국어"
        case .spanish: return "스페인어"
        case .german: return "독일어"
        case .french: return "프랑스어"
        case .italian: return "이탈리아어"
        }
    }
}

enum LanguageLevelType: String, CaseIterable, Identifiable {
    case novice = "NOVICE"
    case beginner = "BEGINNER"
    case intermediate = "INTERMEDIATE"
    case advanced = "ADVANCED"
    case native = "NATIVE"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .novice: return "입문"
        case .beginner: return "초급"
        case .intermediate: return "중급"
        case .advanced: return "고급"
        case .native: return "원어민 수준"
        }
    }
}
