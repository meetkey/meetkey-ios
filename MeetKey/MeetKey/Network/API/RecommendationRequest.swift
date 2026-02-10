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
    var latitude: Double?
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
        if let lat = latitude {dict["latitude"] = lat }
        if let long = longitude {dict["longitude"] = long}
        
        return dict
    }
}
