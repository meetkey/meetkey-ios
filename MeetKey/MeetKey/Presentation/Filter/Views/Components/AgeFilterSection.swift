import SwiftUI

struct AgeFilterSection: View {
    @Binding var minAge: Int?
    @Binding var maxAge: Int?
    @State private var isIgnored: Bool = false

    private let minLimit = 18
    private let maxLimit = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("나이 범위")
                    .font(.meetKey(.body1))
                    .foregroundStyle(Color.text1)

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isIgnored.toggle()
                        if isIgnored {
                            minAge = nil
                            maxAge = nil
                        } else {
                            minAge = minLimit
                            maxAge = maxLimit
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isIgnored ? "checkmark.square.fill" : "square")
                        .foregroundStyle(isIgnored ? Color.orange01 : Color.text4)
                        Text("상관없음")
                            .font(.meetKey(.body4))
                            .foregroundStyle(Color.text2)
                    }
                }
            }

            VStack(spacing: 8) {
                AgeSlider(
                    title: "최소 나이",
                    age: Binding(
                        get: { minAge ?? minLimit },
                        set: { newValue in
                            minAge = newValue
                            if let currentMax = maxAge, newValue > currentMax {
                                maxAge = newValue
                            }
                        }
                    ),
                    range: minLimit...maxLimit,
                    isDisabled: isIgnored
                )

                AgeSlider(
                    title: "최대 나이",
                    age: Binding(
                        get: { maxAge ?? maxLimit },
                        set: { newValue in
                            maxAge = newValue
                            if let currentMin = minAge, newValue < currentMin {
                                minAge = newValue
                            }
                        }
                    ),
                    range: minLimit...maxLimit,
                    isDisabled: isIgnored
                )
            }
            .opacity(isIgnored ? 0.4 : 1.0)
        }
        .onAppear {
            isIgnored = (minAge == nil && maxAge == nil)
        }
    }
}

struct AgeSlider: View {
    let title: String
    @Binding var age: Int
    let range: ClosedRange<Int>
    var isDisabled: Bool = false

    @State private var isDragging = false
    @State private var isEditingText = false
    @FocusState private var isFocused: Bool
    @State private var textInput: String = ""
    @State private var sliderPosition: CGFloat? = nil

    private let trackHeight: CGFloat = 8
    private let thumbSize: CGFloat = 28
    private let bubbleWidth: CGFloat = 50
    private let bubbleColor: Color = .orange
    private let activeTrackColor: Color = .orange01
    private let inactiveTrackColor: Color = .background3

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.meetKey(.body2))
                .foregroundStyle(Color.text2)

            GeometryReader { geometry in
                let trackWidth = geometry.size.width - thumbSize
                let normalizedValue = Double(age - range.lowerBound) / Double(range.upperBound - range.lowerBound)
                let thumbPosition = sliderPosition ?? (CGFloat(normalizedValue) * trackWidth)

                let bubbleHalfWidth = bubbleWidth / 2
                let totalWidth = geometry.size.width
                let preferredCenter = thumbPosition + (thumbSize / 2)
                let clampedBubbleCenter = max(bubbleHalfWidth, min(totalWidth - bubbleHalfWidth, preferredCenter))

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(inactiveTrackColor)
                        .frame(width: geometry.size.width, height: trackHeight)

                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(isDisabled ? inactiveTrackColor : activeTrackColor)
                        .frame(width: thumbPosition + (thumbSize / 2), height: trackHeight)

                    Image(isDisabled ? "slider_thumb_unselect" : "slider_thumb")
                        .resizable()
                        .frame(width: thumbSize, height: thumbSize + 8)
                        .offset(x: thumbPosition)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    if isDisabled { return }
                                    isDragging = true
                                    let absoluteX = gesture.location.x - thumbSize / 2
                                    let clampedX = max(0, min(trackWidth, absoluteX))
                                    sliderPosition = clampedX

                                    let newNormalizedValue = Double(clampedX / trackWidth)
                                    let rawValue = Double(range.lowerBound) + newNormalizedValue * Double(range.upperBound - range.lowerBound)
                                    age = Int(round(rawValue))
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    sliderPosition = nil
                                }
                        )

                    if !isDisabled {
                        ageBubble
                            .frame(width: bubbleWidth)
                            .position(x: clampedBubbleCenter, y: -5)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 60)
        }
    }

    private var ageBubble: some View {
        Group {
            if isEditingText {
                TextField("", text: $textInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.meetKey(.title4))
                    .foregroundStyle(Color.main)
                    .frame(width: 50, height: 32)
                    .background(bubbleColor)
                    .cornerRadius(8)
                    .focused($isFocused)
                    .onSubmit {
                        applyTextInput()
                    }
                    .onChange(of: isFocused) { _, newValue in
                        if !newValue {
                            applyTextInput()
                        }
                    }
            } else {
                Button(action: {
                    if !isDisabled {
                        startEditing()
                    }
                }) {
                    Text("\(age)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white01)
                        .frame(width: 50, height: 32)
                        .background(bubbleColor)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func startEditing() {
        textInput = "\(age)"
        isEditingText = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isFocused = true
        }
    }

    private func applyTextInput() {
        if let newAge = Int(textInput), range.contains(newAge) {
            age = newAge
        }
        isEditingText = false
        isFocused = false
    }
}
