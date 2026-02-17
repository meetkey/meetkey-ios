import SwiftUI

extension Color {
    static let meetKey = MeetKeyColors()
}

struct MeetKeyColors {
    // MARK: - Brand Colors
    let main = Color("Main")        // #F97316
    let sub1 = Color("Sub1")        // #FFEDD5
    
    // MARK: - Text Colors
    let text1 = Color("Text1")      // #000000 (Title)
    let text2 = Color("Text2")      // #1F2937
    let text3 = Color("Text3")      // #6B7280
    let text4 = Color("Text4")      // #9CA3AF
    let text5 = Color("Text5")      // #000000 (40%)
    let text6 = Color("Text6")      // #000000
    let text7 = Color("Text7")      // #000000 (80%)
    let text8 = Color("Text8")      // #000000 (40%)

    // MARK: - Background Colors (띄어쓰기 제거)
    let background1 = Color("Background1") // #F9FAFB (Default BG)
    let background2 = Color("Background2") // #EEEEEE (85%)
    let background3 = Color("Background3") // #C2C2C2 (50%)
    let background4 = Color("Background4") // #C2C2C2 (20%)
    let background5 = Color("Background5") // #000000 (50%)
    let background6 = Color("Background6") // #000000 (50%)
    let background7 = Color("Background7") // #000000 (20%)
    
    // MARK: - Functional & State
    let error = Color("Error")      // #FF5700
    let error2 = Color("Error2")    // #FFE7DA
    let success1 = Color("Success1") // #38ADFE
    let success2 = Color("Success2") // #38ADFE (30%)
    
    let stateDisabled = Color("StateDisabled") // #D9D9D9 (Black04와 동일)
    
    // MARK: - Legacy Colors (디자인 시스템에 없지만 유지해야 하는 색상들)
    let black02 = Color(hex: "C2C2C2")
    let black04 = Color(hex: "D9D9D9") // StateDisabled와 동일
    let black07 = Color(hex: "F0F0F0")
    
    let orange01 = Color(hex: "FF6F00")
    let orange02 = Color(hex: "FFE4CF")
    let orange03 = Color(hex: "FFF3EB")
    
    let white01 = Color(hex: "FFFFFF") // Background1과 유사할 수 있음
    let yellow01 = Color(hex: "FDE500")

    // MARK: - Gradient Components (Bubble1_1 등)
    let bubble1_1 = Color("Bubble1_1")
    let bubble1_2 = Color("Bubble1_2")
    
    let bubble2_1 = Color("Bubble2_1")
    let bubble2_2 = Color("Bubble2_2")
    
    let bubble3_1 = Color("Bubble3_1")
    let bubble3_2 = Color("Bubble3_2")
    
    let stateActive_1 = Color("StateActive_1")
    let stateActive_2 = Color("StateActive_2")
    
    let surface1_1 = Color("Surface1_1")
    let surface1_2 = Color("Surface1_2")
    
    let stroke1_1 = Color("Stroke1_1")
    let stroke1_2 = Color("Stroke1_2")
}

// MARK: - Gradient Extensions
extension LinearGradient {
    static let meetKeyBubble1 = LinearGradient(
        colors: [Color.meetKey.bubble1_1, Color.meetKey.bubble1_2],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let meetKeyBubble2 = LinearGradient(
        colors: [Color.meetKey.bubble2_1, Color.meetKey.bubble2_2],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let meetKeyStateActive = LinearGradient(
        colors: [Color.meetKey.stateActive_1, Color.meetKey.stateActive_2],
        startPoint: .leading, endPoint: .trailing
    )
    
    // ✨ [추가] 스플래시 & 로그인 전용 배경 그라데이션 (#FFFFFF -> #FFF3EB)
        static let meetKeySplash = LinearGradient(
            colors: [Color.meetKey.white01, Color.meetKey.orange03],
            startPoint: .top, endPoint: .bottom
        )
}

// MARK: - Hex Color Helper (Legacy Color 지원용)
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
