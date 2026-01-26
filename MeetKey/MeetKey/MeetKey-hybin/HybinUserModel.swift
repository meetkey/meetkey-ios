//
//  HybinUserModel.swift
//  MeetKey
//
//  Created by 전효빈 on 1/22/26.
//

import Foundation

enum SafeBadge : String, CaseIterable{
    case none  = "none"
    case bronze = "bronze"
    case silver = "silver"
    case gold = "gold"
}

struct User: Identifiable, Equatable {
    let id: UUID
    let name : String
    let age: Int
    let bio : String
    let profileImageURL: String
    let safeBadge: SafeBadge
}
