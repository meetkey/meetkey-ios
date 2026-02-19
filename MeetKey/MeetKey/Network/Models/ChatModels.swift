//
//  ChatModels.swift
//  MeetKey
//
//  Created by 은재 on 2/11/26.
//

import Foundation


enum ChatMessageType: String, Codable {
    case text = "TEXT"
    case image = "IMAGE"
    case voice = "VOICE"
}
