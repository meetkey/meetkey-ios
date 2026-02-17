import SwiftUI

// MARK: - Question Suggestion View
struct QuestionSuggestionList: View {

    let questions: [String]
    let onTapRefresh: () -> Void

    private let orange = Color("Orange01")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // 🔸 상단 주황 버튼
            Button(action: onTapRefresh) {
                Circle()
                    .fill(orange)
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            .padding(.bottom, 6)

            // 🔸 질문 리스트
            ForEach(questions, id: \.self) { question in
                QuestionBubble(text: question)
            }
        }
        .padding(16)
        .background(Color.white) // ✅ 회색 제거
    }
}


// MARK: - Single Bubble
struct QuestionBubble: View {

    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(Color(white: 0.25))
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08),
                            radius: 3,
                            x: 0,
                            y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
    }
}


// MARK: - Preview
#Preview {

    QuestionSuggestionList(
        questions: [
            "How’s the weather today?",
            "How’s your day going so far?",
            "What do you usually do in your free time?",
            "Do you have any favorite cafes or places around here?",
            "What kind of music do you like these days?"
        ],
        onTapRefresh: {
            print("Refresh tapped")
        }
    )
    .padding()
    .background(Color.white)
}
