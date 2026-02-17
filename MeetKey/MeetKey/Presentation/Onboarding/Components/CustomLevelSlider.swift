import SwiftUI

struct CustomLevelSlider: View {
    @Binding var value: Double // Level 1 to 5
    let stepCount = 5
    
    var body: some View {
        VStack(spacing: 8) {
            // Step 1 슬라이더 본체
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                
                ZStack(alignment: .leading) {
                    // Track 배경 회색 선 Black04
                    Rectangle()
                        .fill(Color.meetKey.black04)
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    // Dot 배경 회색 점들 Black04
                    HStack(spacing: 0) {
                        ForEach(0..<stepCount, id: \.self) { index in
                            Circle()
                                .fill(Color.meetKey.black04)
                                .frame(width: 10, height: 10)
                            if index < stepCount - 1 { Spacer() }
                        }
                    }
                    
                    Image("icon_key")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26)
                        .shadow(color: .black.opacity(0.1), radius: 9, x: 0, y: 0)
                        .offset(x: (totalWidth / CGFloat(stepCount - 1)) * CGFloat(value - 1) - 13)
                }
                .frame(height: 22)
                // Touch 터치 영역 및 제스처
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
            .padding(.horizontal, 15) // Slider 본체 여백
            
            // Step 2 텍스트 라벨
            HStack(alignment: .top) {
                VStack(spacing: 4) {
                    Text("초보")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(Color.meetKey.text4)
                    Text("이제 막 시작")
                        .font(.custom("Pretendard-Regular", size: 12))
                        .foregroundColor(Color.meetKey.text4)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("고수")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(Color.meetKey.text4)
                    Text("자유로운 의사소통")
                        .font(.custom("Pretendard-Regular", size: 12))
                        .foregroundColor(Color.meetKey.text4)
                }
            }
            .padding(.top, 4)
            .padding(.horizontal, -18)
        }
        .padding(16)
        .overlay(Rectangle().stroke(Color.clear))
    }
}
