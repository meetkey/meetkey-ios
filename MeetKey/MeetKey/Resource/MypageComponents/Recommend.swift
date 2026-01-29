//
//  Recommend.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct Recommend: View {
    var recommend: Int = 0
    var notRecommend: Int = 0
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("추천")
                    .font(.meetKey(.body5))
                    .foregroundStyle(.black03)
                HStack(alignment: .bottom) {
                    Image(.recommend)
                        .padding(.top, 8)
                        .padding(.trailing, 12)
                    Text("\(recommend)개")
                        .font(.meetKey(.title5))
                        .foregroundStyle(.black01)
                        .padding(.vertical, 2.5)
                }
            }
            .padding(.leading, 12)
            
            Spacer()
            Divider()
                .frame(height: 61)
            
            VStack(alignment: .leading) {
                Text("비추천")
                    .font(.meetKey(.body5))
                    .foregroundStyle(.black03)
                HStack(alignment: .bottom) {
                    Image(.recommend)
                        .padding(.top, 8)
                        .padding(.trailing, 12)
                    Text("\(notRecommend)개")
                        .font(.meetKey(.title5))
                        .foregroundStyle(.black01)
                        .padding(.vertical, 2.5)
                }
            }
            .padding(.leading, 12)
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(.background1)
        .frame(height: 89)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
