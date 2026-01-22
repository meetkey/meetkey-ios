import SwiftUI

extension Color {
    static let meetKeyYellow01 = Color("Yellow01")
    static let meetKeyWhite01 = Color("White01")
    static let meetKeyBlack01 = Color("Black01") // #000000
    static let meetKeyBlack03 = Color("Black03") // #6B7280 (Text 3)
    
    // 배경 그라데이션용 색상 (피그마 Image 4 참고: FFFFFF -> FFF3EB)
    static let bgTop = Color(hex: "FFFFFF")
    static let bgBottom = Color(hex: "FFF3EB")
}

// 16진수 코드로 색상 만들기 위한 확장 (없으면 같이 넣어주세요)
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
