//
//  Badge.swift
//  MeetKey
//
//  Created by sumin Kong on 1/20/26.
//

import SwiftUI

//enum BadgeType: String, CaseIterable {
//    case normal, bronze, silver, gold
//    var image: Image {
//        switch self {
//        case .normal:
//            return Image(.normalBadge)
//        case .bronze:
//            return Image(.bronzeBadge)
//        case .silver:
//            return Image(.silverBadge)
//        case .gold:
//            return Image(.SAFE)
//        }
//    }
//}


struct Badge: View {
    var score: Int
        
    var type: BadgeType {
        BadgeType.from(score: score)
    }
    
    var progress: CGFloat {
        CGFloat(score) / 100.0
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            type.image
                .resizable()
                .scaledToFit()
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Spacer()
                Text("\(score)")
                    .font(.meetKey(.title1))
                Text("점")
                    .font(.meetKey(.body4))
            }
            .foregroundStyle(.white01)
            .padding(.trailing, 20)
            .padding(.top, 33)
            
            progressBar
                .padding(.horizontal, 20)
                .padding(.top, 108)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 136)
    }
}

//extension BadgeType {
//    static func from(score: Int) -> BadgeType {
//        let safeScore = min(max(score, 0), 100)
//        switch safeScore {
//            case 0..<70:
//                return .normal
//            case 70..<80:
//                return .bronze
//            case 80..<90:
//                return .silver
//            default:
//                return .gold
//        }
//    }
//}

private extension Badge {
    var progressBar: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.white.opacity(0.2))
                .frame(width: 290, height: 8)
            Capsule()
                .fill(.white)
                .frame(width: 290 * progress, height: 8)
                .animation(.easeInOut, value: progress)
        }
    }
}


#Preview {
    Badge(score: 90)
}
