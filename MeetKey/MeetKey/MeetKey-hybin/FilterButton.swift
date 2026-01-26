//
//  FilterButton.swift
//  MeetKey
//
//  Created by 전효빈 on 1/26/26.
//

import Foundation
import SwiftUI

struct FilterButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 20))
                .foregroundColor(.black)
                .padding(12)
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}
