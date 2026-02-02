//
//  ReportStep.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import Foundation


enum ReportStep : String, Identifiable {
    case none
    case main
    case block
    case blockComplete
    case report
    case reportCase
    case reportReason
    case reportComplete
    
    var id : String { self.rawValue }
}
