import Foundation

struct APIConfig {
    static let baseURL = "https://meetkey.test-route53.shop"
    static let testToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwicm9sZSI6IlJPTEVfQURNSU4iLCJ0eXBlIjoiYWNjZXNzIiwiaWF0IjoxNzcwNjkyODc1LCJleHAiOjE4MDIyMjg4NzV9.l6I1k82Oc9RMuA37w_X1-xp2xrbXP8CCY87MhbmBmMs"
    // 개발/프로덕션 환경 분리 예시
    

    #if DEBUG
    static let isDebug = true
    #else
    static let isDebug = false
    #endif
}

