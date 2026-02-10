import Foundation

struct APIConfig {
    static let baseURL = "https://meetkey.test-route53.shop"
    
    // 개발/프로덕션 환경 분리 예시
    #if DEBUG
    static let isDebug = true
    #else
    static let isDebug = false
    #endif
}

