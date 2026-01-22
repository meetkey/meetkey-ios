import SwiftUI

extension Font {
    
    // MARK: - 폰트 시스템
    enum MeetKeyFontStyle {
        
        // Titles
        case title1 // 36 Bold
        case title2 // 26 SemiBold
        case title3 // 24 SemiBold
        case title4 // 22 SemiBold
        case title5 // 18 SemiBold
        case title6 // 22 Regular (피그마 표 기준)
        
        // Bodies
        case body1 // 16 SemiBold
        case body2 // 16 Medium
        case body3 // 16 Regular
        case body4 // 14 Medium
        case body5 // 14 Regular
        
        // Captions
        case caption1 // 12 SemiBold
        case caption2 // 12 Medium
        case caption3 // 12 Regular
        case caption4 // 10 Regular
        
        var size: CGFloat {
            switch self {
            case .title1: return 36
            case .title2: return 26
            case .title3: return 24
            case .title4, .title6: return 22
            case .title5: return 18
            case .body1, .body2, .body3: return 16
            case .body4, .body5: return 14
            case .caption1, .caption2, .caption3: return 12
            case .caption4: return 10
            }
        }
        
        var weight: Font.Weight {
            switch self {
            case .title1: return .bold
            case .title2, .title3, .title4, .title5, .body1, .caption1: return .semibold
            case .body2, .body4, .caption2: return .medium
            case .title6, .body3, .body5, .caption3, .caption4: return .regular
            }
        }
    }
    
    // MARK: - 사용 함수
    /// 사용법: .font(.meetKey(.title1))
    static func meetKey(_ style: MeetKeyFontStyle) -> Font {
        // Info.plist에 등록된 폰트 파일명과 정확히 일치해야 합니다.
        let fontName: String
        
        switch style.weight {
        case .bold:
            fontName = "Pretendard-Bold"
        case .semibold:
            fontName = "Pretendard-SemiBold"
        case .medium:
            fontName = "Pretendard-Medium"
        case .regular:
            fontName = "Pretendard-Regular"
        default:
            fontName = "Pretendard-Regular"
        }
        
        return .custom(fontName, size: style.size)
    }
}
