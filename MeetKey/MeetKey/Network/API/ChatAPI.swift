//
//  ChatAPI.swift
//  MeetKey
//
//  Created by 은재 on 2/11/26.
//

import Foundation
import Moya
import Alamofire

enum ChatAPI {
    
    /// 채팅방 목록 조회
    case fetchChatRooms
    
    /// 채팅 메시지 조회
    case fetchMessages(roomId: Int, cursorId: Int?)
    
    /// 채팅방 생성
    case createChatRoom(targetUserId: Int)
    
    /// 읽음 처리
    case markAsRead(roomId: Int)
}

extension ChatAPI: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: APIConfig.baseURL) else {
            fatalError("Invalid base URL: \(APIConfig.baseURL)")
        }
        return url
    }
    
    
    // URL Path
    var path: String {
        switch self {
            
        case .fetchChatRooms:
            return "/chat-room"
            
        case .fetchMessages(let roomId, _):
            return "/chat-room/\(roomId)/messages"
            
        case .createChatRoom:
            return "/chat-room"
            
        case .markAsRead(let roomId):
            return "/chat-room/\(roomId)/read"
        }
    }
    
    
    // HTTP Method
    var method: Moya.Method {
        switch self {
            
        case .fetchChatRooms,
             .fetchMessages:
            return .get
            
        case .createChatRoom:
            return .post
            
        case .markAsRead:
            return .patch
        }
    }
    
    
    // Request Body / Query
    var task: Task {
        switch self {
            
        // 채팅방 목록
        case .fetchChatRooms:
            return .requestPlain
            
            
        // 메시지 조회 (cursor optional)
        case .fetchMessages(_, let cursorId):
            
            if let cursorId = cursorId {
                return .requestParameters(
                    parameters: ["cursorId": cursorId],
                    encoding: URLEncoding.queryString
                )
            } else {
                return .requestPlain
            }
            
            
        // 채팅방 생성
        case .createChatRoom(let targetUserId):
            
            return .requestParameters(
                parameters: ["targetUserId": targetUserId],
                encoding: JSONEncoding.default
            )
            
            
        // 읽음 처리
        case .markAsRead:
            return .requestPlain
        }
    }
    
    
    // Headers
    var headers: [String : String]? {
        
        return [
            "Content-Type": "application/json"
        ]
    }
    
    
    // Status Code Validation
    var validationType: ValidationType {
        return .successCodes
    }
}
