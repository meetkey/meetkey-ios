//
//  RecommendationRequest.swift
//  MeetKey
//
//  Created by 전효빈 on 2/10/26.
//

import Foundation

struct RecommendationRequest : Codable {
    
    var maxDistance : Double?
    var minAge: Int?
    var maxAge: Int?
    var interests: [String]?
    var hometown: String?
    var nativeLanguage: String?
    var targetLanguage: String?
    var targetLanguageLevel: String?
    var personality: [String]?
    var latitude: Double? // 위도 경도는 APP에서 쏴주는 형식으로 (따로 홈뷰에서 관리하다가 한번에 쏴주는 형식)
    var longitude: Double?
    
}

extension RecommendationRequest {
    func toDictionary() -> [String:Any] {
        var dict : [String : Any] = [:]
        if let maxDist = maxDistance {
            dict["maxDistance"] = maxDist
        }
        if let minA = minAge {dict["minAge"] = minA }
        if let maxA = maxAge {dict["maxAge"] = maxA }
        if let ints = interests {dict["interests"] = ints }
        if let home = hometown {dict["hometown"] = home }
        if let natLang = nativeLanguage {dict["nativeLanguage"] = natLang }
        if let tarLang = targetLanguage {dict["targetLanguage"] = tarLang }
        if let tarLangLevel = targetLanguageLevel { dict["targetLanguageLevel"] = tarLangLevel }
        if let pers = personality { dict["personality"] = pers }
        if let lat = latitude {dict["latitude"] = lat }
        if let long = longitude {dict["longitude"] = long}
        
        return dict
    }
}
