//
//  DateFormatter.swift
//  MeetKey
//
//  Created by sumin Kong on 2/4/26.
//
import SwiftUI

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()
}
