import SwiftUI

struct FinishedMatchView: View {
    let size: CGSize
    let safeArea: EdgeInsets
    let action: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { action() }) {
                        Image(systemName: "xmark").foregroundColor(
                            .white.opacity(0.5)
                        )
                    }
                }
                .padding([.top, .trailing], 24)

                contentBody

                descriptionView
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)

                discoverButton
                    .padding(.bottom, 30)
            }
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(white: 0.2).opacity(0.95))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, safeArea.bottom + 40)
        }
    }

}

//MARK: - 컴포넌트
extension FinishedMatchView {

    private var contentBody: some View {
        VStack(spacing: 16) {
            Image("img_meetkey_particle")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)

            VStack(spacing: 8) {
                Text("오늘의 추천 완료!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("내일 새로운 친구들을 만나보세요.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles") 
                    .foregroundColor(.orange)
                Text("친구 추천을 더 받고 싶나요?")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(
                "프리미엄 이용자는 추천 횟수 제한 없이 추가 추천 기능을 사용할 수 있습니다. 보다 다양한 사용자와의 연결을 원하신다면 프리미엄 기능을 확인해 주세요."
            )
            .font(.system(size: 13))
            .foregroundColor(.white.opacity(0.7))
            .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.1))
        )
    }

    private var discoverButton: some View {
        HStack(spacing: 12) {
            Button(action: { action() }) {
                Text("처음으로")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())
            }

            Button(action: { print("자세히 보기 클릭") }) {
                HStack {
                    Text("자세히 보기")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(
                    LinearGradient(
                        colors: [.orange, .red.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
    }
}
