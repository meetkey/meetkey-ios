import Foundation

struct APIConfig {
    static let baseURL = "http://3.36.96.193"
    
    // 개발/프로덕션 환경 분리 예시
    #if DEBUG
    static let isDebug = true
    #else
    static let isDebug = false
    #endif
}

