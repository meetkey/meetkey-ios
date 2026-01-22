import SwiftUI

// 역삼각형 도형
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct LoginView: View {
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [.bgTop, .bgBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // 메인 캐릭터 & 로고 영역
                VStack(spacing: 16) {
                    Image("img_char_meetkey_main")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                    
                    Image("logo_02")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                }
                
                Spacer()
                
                // 로그인 버튼 영역
                VStack(spacing: 12) {
                    
                    // 검증된 소셜 계정 툴팁 (말풍선 + 꼬리)
                    VStack(spacing: -1) { // 틈새 없애기 위해 -1
                        HStack(spacing: 0) {
                            Text("검증된 소셜 계정")
                                .font(.meetKey(.caption1))
                                .foregroundColor(.black)
                            Text("으로 안전하게 로그인하세요.")
                                .font(.meetKey(.caption3))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(4)
                        
                        // 역삼각형 꼬리 추가
                        Triangle()
                            .fill(Color.white)
                            .frame(width: 20, height: 11)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2) // 그림자 통합 적용
                    .padding(.bottom, 4)
                    
                    // 카카오톡 로그인 버튼
                    Button(action: {
                        print("카카오 로그인")
                    }) {
                        ZStack {
                            // Layer 1: 아이콘 (왼쪽 정렬)
                            HStack {
                                Image("img_kakao")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(.leading, 20) // 왼쪽 여백
                                Spacer()
                            }
                            
                            // Layer 2: 텍스트 (가운데 정렬)
                            Text("카카오톡으로 시작하기")
                                .font(.meetKey(.body2))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.meetKeyYellow01)
                        .cornerRadius(14)
                    }
                    
                    // Apple 로그인 버튼
                    Button(action: {
                        print("애플 로그인")
                    }) {
                        ZStack {
                            // Layer 1: 아이콘
                            HStack {
                                Image("img_apple")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 20)
                                    .foregroundColor(.meetKeyBlack01)
                                    .padding(.leading, 20)
                                Spacer()
                            }
                            
                            // Layer 2: 텍스트
                            Text("Apple로 시작하기")
                                .font(.meetKey(.body2))
                                .foregroundColor(.meetKeyBlack01)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.meetKeyWhite01)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.meetKeyBlack01, lineWidth: 1)
                        )
                    }
                    
                    // 계정 찾기
                    Button(action: {
                        print("계정 찾기")
                    }) {
                        Text("계정 찾기")
                            .font(.meetKey(.body5))
                            .foregroundColor(.meetKeyBlack03)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    LoginView()
}
