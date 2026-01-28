import SwiftUI

extension Color {
    static let meetKeyYellow01 = Color("Yellow01")
        static let meetKeyWhite01 = Color("White01")
        static let meetKeyBlack01 = Color("Black01")
        static let meetKeyBlack02 = Color("Black02")
        static let meetKeyBlack03 = Color("Black03")
        static let meetKeyBlack04 = Color("Black04")
        static let meetKeyBlack05 = Color("Black05")
        static let meetKeyBlack06 = Color("Black06")
        static let meetKeyBlack07 = Color("Black07")
        
        static let meetKeyOrange04 = Color("Orange04")
        static let meetKeyOrange05 = Color("Orange05")
        static let meetKeyOrange06 = Color("Orange06")
        static let meetKeyOrange07 = Color("Orange07")
    
        // 배경 그라데이션용 색상
        static let bgTop = Color(hex: "FFFFFF")
        static let bgBottom = Color(hex: "FFF3EB")
}

// 16진수 코드로 색상 만들기 위한 확장
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
