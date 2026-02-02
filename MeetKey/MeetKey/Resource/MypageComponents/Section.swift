//
//  Section.swift
//  MeetKey
//
//  Created by sumin Kong on 1/22/26.
//

import SwiftUI

struct Section: View {
    var title: String
    var isMore: Bool = true
    var body: some View {
        HStack {
            Text(title)
                .font(.meetKey(.body1))
                .foregroundColor(.primary)
            Spacer()
            if isMore {
                Image(.more)
            }
        }
        .frame(height: 24)
    }
}

#Preview {
    Section(title: "Hello World")
        .background(.red)
}
