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
    
    var isRecommended: Bool = false
    var isNotRecommended: Bool = false
    
    var onRecommendTap: (() -> Void)? = nil
    var onNotRecommendTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                onRecommendTap?()
            } label: {
                VStack(alignment: .leading) {
                    Text("추천")
                        .font(.meetKey(.body5))
                        .foregroundStyle(.text3)
                    
                    HStack(alignment: .bottom) {
                        Image(.recommend)
                        Text("\(recommend)개")
                            .font(.meetKey(.title5))
                            .foregroundStyle(isRecommended ? .blue : .text1)
                    }
                }
                .padding(.leading, 12)
            }
            
            Spacer()
            
            Divider()
                .frame(height: 61)
            
            Button {
                onNotRecommendTap?()
            } label: {
                VStack(alignment: .leading) {
                    Text("비추천")
                        .font(.meetKey(.body5))
                        .foregroundStyle(.text3)
                    
                    HStack(alignment: .bottom) {
                        Image(.notRecommend)
                        Text("\(notRecommend)개")
                            .font(.meetKey(.title5))
                            .foregroundStyle(.text1)
                    }
                }
                .padding(.leading, 12)
            }
            
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(.background1)
        .frame(height: 89)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
