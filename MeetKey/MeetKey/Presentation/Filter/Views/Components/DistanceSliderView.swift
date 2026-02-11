

import SwiftUI

// MARK: - Distance Filter Section View
struct DistanceFilterSection: View {
    @Binding var maxDistance: Double?
    @State private var isIgnored: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("최대 거리")
                .font(.meetKey(.body4))
                .foregroundColor(.text3)
            
            DistanceFilterButtons(
                maxDistance: $maxDistance,
                isIgnored: $isIgnored
            )
        }
        .onAppear {
            // 초기값이 nil이면 "상관없음" 체크 상태로 시작
            isIgnored = (maxDistance == nil)
        }
    }
}

// MARK: - Distance Filter Buttons Component
struct DistanceFilterButtons: View {
    @Binding var maxDistance: Double?
    @Binding var isIgnored: Bool
    
    // 스텝 정의
    private let steps: [Double] = [5, 10, 20, 30, 50]
    private let labels = ["5km", "10km", "20km", "30km", "50km"]
    private let descriptions = ["가까운\n거리", "인근\n지역", "같은\n도시권", "넓은\n범위", "광역\n범위"]
    
    // 디자인 속성
    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 32
    private let activeColor: Color = .blue
    private let inactiveColor: Color = .gray.opacity(0.3)
    private let keyColor: Color = .orange
    
    @State private var tempValue: Double = 20 // 체크박스 해제 시 복원용
    
    var body: some View {
        VStack(spacing: 20) {
            // 상관없음 체크박스
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isIgnored.toggle()
                        if isIgnored {
                            // 체크 시: 현재 값 저장 후 nil로 설정
                            if let current = maxDistance {
                                tempValue = current
                            }
                            maxDistance = nil
                        } else {
                            // 체크 해제 시: 이전 값 복원
                            maxDistance = tempValue
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isIgnored ? "checkmark.square.fill" : "square")
                            .foregroundColor(isIgnored ? .blue : .gray)
                        Text("상관없음")
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // 현재 선택된 거리 표시
                if let distance = maxDistance {
                    Text("최대 \(Int(distance))km")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // 탭 기반 슬라이더
            tapSliderView
                .opacity(isIgnored ? 0.4 : 1.0)
                .disabled(isIgnored)
        }
    }
    
    private var tapSliderView: some View {
        VStack(spacing: 16) {
            // 슬라이더 본체 (탭으로 위치 선택)
            GeometryReader { geometry in
                let trackWidth = geometry.size.width - thumbSize
                let stepWidth = trackWidth / CGFloat(steps.count - 1)
                let currentIndex = currentStepIndex
                let thumbPosition = stepWidth * CGFloat(currentIndex)
                
                ZStack(alignment: .leading) {
                    // 전체 탭 가능 영역 (투명 오버레이)
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { gesture in
                                    if isIgnored { return }
                                    
                                    // 탭한 위치에서 가장 가까운 스텝 찾기
                                    let tapX = gesture.location.x - thumbSize / 2
                                    let clampedX = max(0, min(trackWidth, tapX))
                                    let nearestIndex = Int(round(clampedX / stepWidth))
                                    let validIndex = max(0, min(steps.count - 1, nearestIndex))
                                    
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        maxDistance = steps[validIndex]
                                        tempValue = steps[validIndex]
                                    }
                                }
                        )
                    
                    // 연결선 배경
                    Rectangle()
                        .fill(isIgnored ? inactiveColor : inactiveColor)
                        .frame(width: trackWidth, height: trackHeight)
                        .offset(x: thumbSize / 2, y: thumbSize / 2 - trackHeight / 2)
                    
                    // 활성 라인 (선택된 위치까지)
                    if !isIgnored, currentIndex > 0 {
                        Rectangle()
                            .fill(activeColor)
                            .frame(width: thumbPosition, height: trackHeight)
                            .offset(x: thumbSize / 2, y: thumbSize / 2 - trackHeight / 2)
                    }
                    
                    // 스텝 포인트 (작은 원)
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(
                                        isIgnored ? inactiveColor :
                                        (index <= currentIndex ? activeColor : Color.gray.opacity(0.4)),
                                        lineWidth: 2
                                    )
                            )
                            .offset(
                                x: stepWidth * CGFloat(index) + thumbSize / 2 - 5,
                                y: thumbSize / 2 - 5
                            )
                    }
                    
                    // 열쇠 Thumb (드래그 불가, 애니메이션으로만 이동)
                    VStack(spacing: 4) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 18))
                            .foregroundColor(isIgnored ? .gray.opacity(0.4) : keyColor)
                        
                        Text(labels[currentIndex])
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(isIgnored ? .secondary : .primary)
                    }
                    .frame(width: thumbSize, height: thumbSize + 16)
                    .offset(x: thumbPosition)
                }
                .frame(height: thumbSize + 16)
            }
            .frame(height: thumbSize + 16)
            
            // 설명 라벨
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Text(descriptions[index])
                        .font(.caption2)
                        .foregroundColor(
                            isIgnored ? .gray.opacity(0.6) :
                            (index == currentStepIndex ? .primary : .secondary)
                        )
                        .fontWeight(index == currentStepIndex ? .medium : .regular)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // 현재 선택된 스텝 인덱스 계산
    private var currentStepIndex: Int {
        guard let distance = maxDistance else {
            return steps.firstIndex(of: tempValue) ?? 2
        }
        return steps.firstIndex(of: distance) ?? 2
    }
}
