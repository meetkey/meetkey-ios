//
//  BlockBtn.swift
//  MeetKey
//
//  Created by sumin Kong on 2/2/26.
//

import SwiftUI

struct BlockBtn: View {
    
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.meetKey(.title5))
                .foregroundStyle(.black06)
                .frame(height: 25)
                
        }
        .frame(height: 54)
        .frame(maxWidth: .infinity)
        .background(.background2)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
