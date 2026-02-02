import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    // 1. 입력값
    @Published var phoneNumber: String = ""
    @Published var verifyCode: String = ""
    
    // 2. 화면 상태
    @Published var isCodeSent: Bool = false   // 인증번호 보냈는지 (입력창 띄우기용)
    @Published var isVerified: Bool = false   // 인증 성공했는지 (버튼 색깔 바꾸기용)
    
    // 3. 기능들
    // [단계 1] 인증번호 보내기 버튼 눌렀을 때
    func sendCode() {
        print("인증번호 발송!")
        withAnimation {
            isCodeSent = true
        }
    }
    
    // [단계 2] 인증 확인하기 버튼 눌렀을 때
    func checkCode() {
        // (임시) 123456 이라고 치면 통과
        if verifyCode == "123456" {
            withAnimation {
                isVerified = true // 성공 -> 버튼 주황색으로 변신
            }
            print("인증 성공")
        } else {
            print("인증 실패: 번호를 확인하세요")
        }
    }
    
    // [단계 3] 로그인 하기 버튼 눌렀을 때
    func login() {
        print("로그인 API 호출!")
    }
}
