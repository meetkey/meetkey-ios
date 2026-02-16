//
//  OtherEvaluationRequestDTO.swift
//  MeetKey
//
//  Created by sumin Kong on 2/17/26.
//

enum EvaluationType: String, Encodable {
    case recommend = "RECOMMEND"
    case notRecommend = "NOT_RECOMMEND"
}

struct EvaluationRequestDTO: Encodable {
    let targetMemberId: Int
    let type: EvaluationType
}
