import SwiftUI

struct CustomLevelSlider: View {
    @Binding var value: Double // 1.0 ~ 5.0
    let stepCount = 5
    
    var body: some View {
        VStack(spacing: 8) {
            // 1. 슬라이더 본체
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                
                ZStack(alignment: .leading) {
                    // [배경] 회색 선 (트랙) - ✨ Black04로 변경
                    Rectangle()
                        .fill(Color.meetKeyBlack04)
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    // [배경] 회색 점들 - ✨ Black04로 변경
                    HStack(spacing: 0) {
                        ForEach(0..<stepCount, id: \.self) { index in
                            Circle()
                                .fill(Color.meetKeyBlack04)
                                .frame(width: 10, height: 10)
                            if index < stepCount - 1 { Spacer() }
                        }
                    }
                    
                    // [활성] 주황색 핸들 (왕 큰 점)
                    Circle()
                        .fill(Color.meetKeyOrange04)
                        .frame(width: 22, height: 22)
                        .shadow(color: .black.opacity(0.1), radius: 9, x: 0, y: 0)
                        // 위치 계산 로직
                        .offset(x: (totalWidth / CGFloat(stepCount - 1)) * CGFloat(value - 1) - 11)
                }
                .frame(height: 22)
                // 터치 영역 및 제스처
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let percentage = min(max(0, gesture.location.x / totalWidth), 1)
                            let newStep = round(percentage * Double(stepCount - 1)) + 1
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                value = newStep
                            }
                        }
                )
            }
            .frame(height: 22)
            .padding(.horizontal, 15) // 슬라이더 본체의 여백
            
            // 2. 텍스트 라벨
            HStack(alignment: .top) {
                VStack(spacing: 4) {
                    Text("초보")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(.meetKeyBlack06)
                    Text("이제 막 시작")
                        .font(.custom("Pretendard-Regular", size: 12))
                        .foregroundColor(.meetKeyBlack05)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("고수")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(.meetKeyBlack06)
                    Text("자유로운 의사소통")
                        .font(.custom("Pretendard-Regular", size: 12))
                        .foregroundColor(.meetKeyBlack05)
                }
            }
            .padding(.top, 4)
            .padding(.horizontal, -18)
        }
        .padding(16)
        .overlay(Rectangle().stroke(Color.clear))
    }
}
