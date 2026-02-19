import SwiftUI

// Tooltip 꼬리 모양
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
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var appleSignInCoordinator = AppleSignInCoordinator()
    @StateObject private var kakaoSignInCoordinator = KakaoSignInCoordinator()
    @State private var navigateToOnboarding = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.meetKeySplash
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    
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
                    
                    VStack(spacing: 12) {
                        // Social 로그인 안내 툴팁
                        VStack(spacing: -1) {
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
                            .cornerRadius(5)
                            
                            Triangle()
                                .fill(Color.white)
                                .frame(width: 20, height: 11)
                        }
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(.bottom, 4)
                        
                        Button(action: {
                            handleKakaoLogin()
                        }) {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    HStack {
                                        Image("img_kakao")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .padding(.leading, 20)
                                        Spacer()
                                    }
                                    
                                    Text("카카오톡으로 시작하기")
                                        .font(.meetKey(.body2))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.meetKey.yellow01)
                            .cornerRadius(14)
                        }
                        .disabled(viewModel.isLoading)
                        
                        Button(action: {
                            handleAppleLogin()
                        }) {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    // Layer 1 아이콘
                                    HStack {
                                        Image("img_apple")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 20)
                                            .padding(.leading, 20)
                                        Spacer()
                                    }

                                    // Layer 2 텍스트
                                    Text("Apple로 시작하기")
                                        .font(.meetKey(.body2))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.meetKey.background1)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.meetKey.text1, lineWidth: 1)
                            )
                        }
                        .disabled(viewModel.isLoading)
                        .padding(.top, 1)
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.meetKey(.caption3))
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
            .navigationDestination(isPresented: $navigateToOnboarding) {
                OnboardingIntroView()
            }
            .onChange(of: viewModel.isLoginSuccess) { _, success in
                if success {
                    navigateToOnboarding = true
                }
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToSignup) {
                OnboardingIntroView()
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToHome) {
                ChatListView()
            }
        }
    }
    
    // Kakao 로그인
    private func handleKakaoLogin() {
        viewModel.errorMessage = nil
        kakaoSignInCoordinator.startSignIn { result in
            switch result {
            case .success(let token):
                viewModel.loginWithKakao(idToken: token)
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }
    
    // Apple 로그인
    private func handleAppleLogin() {
        viewModel.errorMessage = nil
        appleSignInCoordinator.startSignIn { result in
            switch result {
            case .success(let tokens):
                viewModel.loginWithApple(idToken: tokens.identityToken)
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    LoginView()
}
