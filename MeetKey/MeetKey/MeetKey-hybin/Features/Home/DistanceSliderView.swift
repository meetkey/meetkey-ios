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
            
            // 버튼식 슬라이더
            buttonSliderView
                .opacity(isIgnored ? 0.4 : 1.0)
                .disabled(isIgnored)
        }
    }
    
    private var buttonSliderView: some View {
        VStack(spacing: 16) {
            // 버튼 + 연결선
            GeometryReader { geometry in
                let buttonWidth: CGFloat = 56
                let totalWidth = geometry.size.width
                let spacing = (totalWidth - buttonWidth * CGFloat(steps.count)) / CGFloat(steps.count - 1)
                let stepWidth = buttonWidth + spacing
                
                ZStack(alignment: .leading) {
                    // 연결선 배경
                    connectionLineView(
                        totalWidth: totalWidth,
                        buttonWidth: buttonWidth,
                        stepWidth: stepWidth
                    )
                    
                    // 버튼들
                    HStack(spacing: spacing) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            distanceButton(
                                distance: steps[index],
                                label: labels[index],
                                isSelected: maxDistance == steps[index]
                            )
                            .frame(width: buttonWidth)
                        }
                    }
                }
            }
            .frame(height: 56)
            
            // 설명 라벨
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Text(descriptions[index])
                        .font(.caption2)
                        .foregroundColor(isIgnored ? .gray.opacity(0.6) : .secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // 연결선 그리기
    private func connectionLineView(totalWidth: CGFloat, buttonWidth: CGFloat, stepWidth: CGFloat) -> some View {
        let currentIndex = currentStepIndex
        
        return ZStack(alignment: .leading) {
            // 전체 배경 라인
            Rectangle()
                .fill(isIgnored ? inactiveColor : inactiveColor)
                .frame(width: totalWidth - buttonWidth, height: 3)
                .offset(x: buttonWidth / 2, y: 28)
            
            // 활성 라인 (선택된 위치까지)
            if !isIgnored, currentIndex > 0 {
                Rectangle()
                    .fill(activeColor)
                    .frame(width: stepWidth * CGFloat(currentIndex), height: 3)
                    .offset(x: buttonWidth / 2, y: 28)
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
                    .offset(x: stepWidth * CGFloat(index) + buttonWidth / 2 - 5, y: 28 - 5)
            }
        }
    }
    
    // 거리 버튼
    private func distanceButton(distance: Double, label: String, isSelected: Bool) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if !isIgnored {
                    maxDistance = distance
                    tempValue = distance
                }
            }
        }) {
            VStack(spacing: 4) {
                // 열쇠 아이콘
                Image(systemName: "key.fill")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected && !isIgnored ? keyColor : .gray.opacity(0.4))
                
                // 거리 라벨
                Text(label)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected && !isIgnored ? .primary : .secondary)
            }
            .frame(width: 56, height: 56)
            .background(
                Circle()
                    .fill(isSelected && !isIgnored ? Color.white : Color.gray.opacity(0.05))
                    .shadow(
                        color: isSelected && !isIgnored ? .black.opacity(0.1) : .clear,
                        radius: 6,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                Circle()
                    .stroke(
                        isSelected && !isIgnored ? activeColor : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected && !isIgnored ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 현재 선택된 스텝 인덱스 계산
    private var currentStepIndex: Int {
        guard let distance = maxDistance else {
            return steps.firstIndex(of: tempValue) ?? 2
        }
        return steps.firstIndex(of: distance) ?? 2
    }
}


