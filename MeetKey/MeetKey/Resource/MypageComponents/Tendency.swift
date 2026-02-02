//
//  Tendency.swift
//  MeetKey
//
//  Created by sumin Kong on 1/22/26.
//

import SwiftUI

struct Tendency: View {
    var personality: String
    var value: String
    var isLineHidden: Bool = false
    
    var body: some View {
        HStack {
            Text(personality)
                .font(.meetKey(.body5))
                .foregroundStyle(.black03)
            Spacer()
            Text(value)
                .font(.meetKey(.body4))
                .foregroundStyle(.black06)
        }
        .frame(height: 44)
        
        .overlay(alignment: .bottom) {
            if !isLineHidden {
                Rectangle()
                    .fill(.background1)
                    .frame(height: 1)
            }
        }
    }
}
