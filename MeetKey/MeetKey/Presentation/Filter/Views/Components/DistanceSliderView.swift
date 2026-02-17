import SwiftUI

struct DistanceFilterSection: View {
    @Binding var maxDistance: Double?

    var body: some View {
        VStack {
            DistanceFilterButtons(maxDistance: $maxDistance)
        }
    }
}

struct DistanceFilterButtons: View {
    @Binding var maxDistance: Double?

    private var isIgnored: Bool { maxDistance == nil }

    private let steps: [Double] = [5, 10, 20, 30, 50]
    private let labels = ["5km", "10km", "20km", "30km", "50km"]
    private let descriptions = [
        "가까운\n거리", "인근\n지역", "같은\n도시권", "넓은\n범위", "광역\n범위",
    ]

    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 28
    private let activeTrackColor: Color = .orange01
    private let inactiveTrackColor: Color = .background3

    @State private var tempValue: Double = 20

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("최대 거리")
                    .font(.meetKey(.body1))
                    .foregroundStyle(.text1)

                Spacer()

                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if maxDistance == nil {
                                maxDistance = tempValue
                            } else {
                                tempValue = maxDistance!
                                maxDistance = nil
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(
                                systemName: isIgnored
                                    ? "checkmark.square.fill" : "square"
                            )
                            .foregroundStyle(
                                isIgnored ? Color.orange01 : Color.text4
                            )
                            Text("상관없음")
                                .font(.meetKey(.body4))
                                .foregroundStyle(Color.text2)
                        }
                    }
                }
            }

            VStack(spacing: 8) {
                GeometryReader { geometry in
                    let trackWidth = geometry.size.width - thumbSize
                    let stepWidth =
                        trackWidth / CGFloat(steps.count - 1)
                    let currentIndex = currentStepIndex
                    let thumbPosition =
                        stepWidth * CGFloat(currentIndex)

                    ZStack(alignment: .leading) {
                        RoundedRectangle(
                            cornerRadius: trackHeight / 2
                        )
                        .fill(inactiveTrackColor)
                        .frame(
                            width: geometry.size.width,
                            height: trackHeight
                        )

                        RoundedRectangle(
                            cornerRadius: trackHeight / 2
                        )
                        .fill(
                            isIgnored
                                ? inactiveTrackColor
                                : activeTrackColor
                        )
                        .frame(
                            width: thumbPosition + (thumbSize / 2),
                            height: trackHeight
                        )

                        ForEach(0..<steps.count, id: \.self) { index in
                            let pointSize: CGFloat = 12
                            let pointX =
                                stepWidth * CGFloat(index)
                                + (thumbSize / 2)

                            Circle()
                                .fill(
                                    isIgnored
                                        ? Color.clear
                                        : (index <= currentIndex
                                            ? Color.main
                                            : Color.background3)
                                )
                                .frame(
                                    width: pointSize,
                                    height: pointSize
                                )
                                .offset(
                                    x: pointX - (pointSize / 2)
                                )
                        }

                        Image(
                            isIgnored
                                ? "slider_thumb_unselect"
                                : "slider_thumb"
                        )
                        .resizable()
                        .frame(
                            width: thumbSize,
                            height: thumbSize + 8
                        )
                        .offset(x: thumbPosition)

                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(
                                    minimumDistance: 0
                                )
                                .onEnded { gesture in
                                    if isIgnored { return }
                                    let tapX =
                                        gesture.location.x
                                        - thumbSize / 2
                                    let clampedX = max(
                                        0,
                                        min(trackWidth, tapX)
                                    )
                                    let nearestIndex = Int(
                                        round(
                                            clampedX
                                                / stepWidth
                                        )
                                    )

                                    withAnimation(
                                        .spring(
                                            response: 0.3,
                                            dampingFraction: 0.7
                                        )
                                    ) {
                                        maxDistance =
                                            steps[nearestIndex]
                                        tempValue =
                                            steps[nearestIndex]
                                    }
                                }
                            )
                    }
                    .frame(
                        maxHeight: .infinity,
                        alignment: .center
                    )
                }
                .frame(height: 40)

                HStack(alignment: .top, spacing: 0) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        VStack(spacing: 4) {
                            Text(labels[index])
                                .font(.meetKey(.body2))
                                .foregroundStyle(
                                    index == currentStepIndex
                                        && !isIgnored
                                        ? Color.main
                                        : Color.text4
                                )

                            Text(descriptions[index])
                                .font(.system(size: 10))
                                .foregroundStyle(
                                    index == currentStepIndex
                                        && !isIgnored
                                        ? Color.text1
                                        : Color.text4
                                )
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .opacity(isIgnored ? 0.5 : 1.0)
        }
    }

    private var currentStepIndex: Int {
        let valueToFind = maxDistance ?? tempValue
        return steps.firstIndex(of: valueToFind) ?? 2
    }
}
