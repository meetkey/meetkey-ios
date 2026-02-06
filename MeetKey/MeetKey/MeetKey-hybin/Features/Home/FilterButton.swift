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
                .font(.meetKey(.title6))
                .foregroundStyle(Color.black)
                .padding(12)
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())

        }
        .frame(width:50, height: 50)
    }
}
