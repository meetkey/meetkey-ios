import SwiftUI

// MARK: - Age Filter Section View
struct AgeFilterSection: View {
    @Binding var minAge: Int?
    @Binding var maxAge: Int?
    @State private var isIgnored: Bool = false

    private let minLimit = 18
    private let maxLimit = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 섹션 타이틀
            HStack {
                Text("나이 범위")
                    .font(.meetKey(.body1))
                    .foregroundColor(.text1)

                Spacer()

                // 상관없음 체크박스
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
                        Image(
                            systemName: isIgnored
                                ? "checkmark.square.fill" : "square"
                        )
                        .foregroundColor(isIgnored ? .orange01 : .gray)
                        Text("상관없음")
                            .foregroundColor(.primary)
                            .font(.subheadline)
                    }
                }
            }

            VStack(spacing: 8) {
                // 최소 나이 슬라이더
                AgeSlider(
                    title: "최소 나이",
                    age: Binding(
                        get: { minAge ?? minLimit },
                        set: { newValue in
                            minAge = newValue
                            // 역전 방지: 최소 나이가 현재 최대 나이보다 커지면 최대 나이도 같이 올림
                            if let currentMax = maxAge, newValue > currentMax {
                                maxAge = newValue
                            }
                        }
                    ),
                    range: minLimit...maxLimit,
                    isDisabled: isIgnored
                )

                // 최대 나이 슬라이더
                AgeSlider(
                    title: "최대 나이",
                    age: Binding(
                        get: { maxAge ?? maxLimit },
                        set: { newValue in
                            maxAge = newValue
                            // 역전 방지: 최대 나이가 현재 최소 나이보다 작아지면 최소 나이도 같이 내림
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

// MARK: - Age Slider Component
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
    
    // 디자인 속성 (피그마 기준 업데이트)
    private let trackHeight: CGFloat = 14 // 4 + 10 반영
    private let thumbSize: CGFloat = 28
    private let bubbleWidth: CGFloat = 50
    private let bubbleColor: Color = .orange
    private let activeTrackColor: Color = .orange01
    private let inactiveTrackColor: Color = .background3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) { // 나이 타이틀과 슬라이더 간격
            Text(title)
                .font(.meetKey(.body2))
                .foregroundStyle(Color.text2)
            
            GeometryReader { geometry in
                // 트랙의 실제 가동 범위
                let trackWidth = geometry.size.width - thumbSize
                let normalizedValue = Double(age - range.lowerBound) / Double(range.upperBound - range.lowerBound)
                let thumbPosition = sliderPosition ?? (CGFloat(normalizedValue) * trackWidth)
                
                // 말풍선 클램핑 로직
                let bubbleHalfWidth = bubbleWidth / 2
                let totalWidth = geometry.size.width
                let preferredCenter = thumbPosition + (thumbSize / 2)
                let clampedBubbleCenter = max(bubbleHalfWidth, min(totalWidth - bubbleHalfWidth, preferredCenter))
                
                ZStack(alignment: .leading) {
                    // 1. 전체 트랙 배경 (화면 너비 전체 활용)
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(inactiveTrackColor)
                        .frame(width: geometry.size.width, height: trackHeight)
                    
                    // 2. 활성 트랙 (Thumb의 중앙까지 채움)
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(isDisabled ? inactiveTrackColor : activeTrackColor)
                        .frame(width: thumbPosition + (thumbSize / 2), height: trackHeight)
                    
                    // 3. 커스텀 Thumb 이미지
                    Image(isDisabled ? "slider_thumb_unselect" : "slider_thumb")
                        .resizable()
                        .frame(width: thumbSize, height: thumbSize + 8) // 세로로 살짝 긴 피그마 느낌 반영
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

                    // 4. 말풍선 (Thumb과의 간격 최적화)
                    if !isDisabled {
                        ageBubble
                            .frame(width: bubbleWidth)
                            // y값을 미세 조정하여 슬라이더와 겹치지 않으면서 가깝게 배치
                            .position(x: clampedBubbleCenter, y: -5)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center) // ZStack을 GeometryReader 중앙에 배치
            }
            .frame(height: 60) // 슬라이더 터치 및 말풍선 영역 확보
        }
    }
    // 말풍선 뷰
    private var ageBubble: some View {
        Group {
            if isEditingText {
                // 편집 모드: TextField
                TextField("", text: $textInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.meetKey(.title4))
                    .foregroundColor(.main)
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
                // 표시 모드: 숫자 표시
                Button(action: {
                    if !isDisabled {
                        startEditing()
                    }
                }) {
                    Text("\(age)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 32)
                        .background(bubbleColor)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // 편집 시작
    private func startEditing() {
        textInput = "\(age)"
        isEditingText = true
        // 약간의 딜레이 후 포커스 (SwiftUI 렌더링 타이밍 이슈 방지)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isFocused = true
        }
    }

    // 텍스트 입력 적용
    private func applyTextInput() {
        if let newAge = Int(textInput), range.contains(newAge) {
            age = newAge
        }
        isEditingText = false
        isFocused = false
    }
}
