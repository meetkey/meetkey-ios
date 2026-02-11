import SwiftUI

// MARK: - Age Filter Section View
struct AgeFilterSection: View {
    @Binding var minAge: Int?
    @Binding var maxAge: Int?
    @State private var isIgnored: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 섹션 타이틀
            HStack {
                Text("나이")
                    .font(.meetKey(.body4))
                    .foregroundColor(.text3)
                
                Spacer()
                
                // 상관없음 체크박스
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isIgnored.toggle()
                        if isIgnored {
                            minAge = nil
                            maxAge = nil
                        } else {
                            minAge = 18
                            maxAge = 50
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isIgnored ? "checkmark.square.fill" : "square")
                            .foregroundColor(isIgnored ? .blue : .gray)
                        Text("상관없음")
                            .foregroundColor(.primary)
                            .font(.subheadline)
                    }
                }
            }
            
            VStack(spacing: 24) {
                // 최소 나이 슬라이더
                AgeSlider(
                    title: "최소 나이",
                    age: Binding(
                        get: { minAge ?? 18 },
                        set: { minAge = $0 }
                    ),
                    range: 18...50,
                    isDisabled: isIgnored
                )
                
                // 최대 나이 슬라이더
                AgeSlider(
                    title: "최대 나이",
                    age: Binding(
                        get: { maxAge ?? 50 },
                        set: { maxAge = $0 }
                    ),
                    range: 18...50,
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
    @State private var sliderPosition: CGFloat? = nil // 드래그 중 위치 추적
    
    // 디자인 속성
    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 28
    private let bubbleColor: Color = .orange
    private let activeTrackColor: Color = .gray.opacity(0.3)
    private let inactiveTrackColor: Color = .gray.opacity(0.15)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 타이틀
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 슬라이더
            GeometryReader { geometry in
                let trackWidth = geometry.size.width - thumbSize
                let normalizedValue = Double(age - range.lowerBound) / Double(range.upperBound - range.lowerBound)
                let calculatedPosition = CGFloat(normalizedValue) * trackWidth
                let thumbPosition = sliderPosition ?? calculatedPosition
                
                ZStack(alignment: .leading) {
                    // 트랙 배경
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(inactiveTrackColor)
                        .frame(height: trackHeight)
                        .offset(x: thumbSize / 2)
                    
                    // 활성 트랙
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(activeTrackColor)
                        .frame(width: thumbPosition, height: trackHeight)
                        .offset(x: thumbSize / 2)
                    
                    // Thumb + 말풍선
                    VStack(spacing: 8) {
                        // 말풍선 (숫자 표시 + 편집 가능)
                        ageBubble
                        
                        // Thumb (동그라미)
                        Circle()
                            .fill(bubbleColor)
                            .frame(width: thumbSize, height: thumbSize)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                    .offset(x: thumbPosition)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                if isDisabled { return }
                                isDragging = true
                                
                                // 절대 위치 기반 계산
                                let absoluteX = gesture.location.x - thumbSize / 2
                                let clampedPosition = max(0, min(trackWidth, absoluteX))
                                
                                sliderPosition = clampedPosition
                                
                                let newNormalizedValue = Double(clampedPosition / trackWidth)
                                let rawValue = Double(range.lowerBound) + newNormalizedValue * Double(range.upperBound - range.lowerBound)
                                
                                // 정수로 반올림
                                let newAge = Int(round(rawValue))
                                age = max(range.lowerBound, min(range.upperBound, newAge))
                            }
                            .onEnded { _ in
                                isDragging = false
                                sliderPosition = nil // 드래그 종료 시 계산된 위치로 복귀
                            }
                    )
                }
                .frame(height: thumbSize + 40) // 말풍선 공간 포함
            }
            .frame(height: thumbSize + 40)
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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
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

