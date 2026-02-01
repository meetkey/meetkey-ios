//
//  HybinProfileSectionView.swift
//
//
//  Created by 전효빈 on 1/15/26.
//

import SwiftUI

struct HybinProfileSectionView: View {
    let size: CGSize
    let user: User
    var body: some View {
        ZStack(alignment: .top) {

            Image(user.profileImageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()
            
            LinearGradient(
                colors:[.black.opacity(0.7), .black.opacity(0.1)],
                startPoint: .bottom,
                endPoint: .center
            )

            Spacer()
            VStack {
                HStack {
                    Spacer()
                    Text(user.safeBadge.rawValue)
                        .foregroundStyle(Color.orange)
                }
                Spacer()
                Text(user.name)
                    .font(.title)
                    .foregroundStyle(Color.white)

            }
            .frame(width: size.width, height: size.height * 0.7)
        }
    }
}
