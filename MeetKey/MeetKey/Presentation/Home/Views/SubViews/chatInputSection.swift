//
//  chatInputSection.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import SwiftUI

struct ChatInputSection: View {
    @Binding var messageText: String


    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Button(action: { /* 주제 추천 로직 */  }) {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 12))
                    Text("대화 주제 추천 받기 5/5")
                        .font(.system(size: 13, weight: .medium))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundColor(.orange)
                .overlay(
                    Capsule().stroke(Color.orange, lineWidth: 1)
                )
            }
            .padding(.leading, 20)

            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                }

                TextField("Type a message", text: $messageText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(25)

                Button(action: { /* 메시지 전송 */  }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color.white)
    }

}
