import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct MEETKEYApp: App {
    init() {
        KakaoSDK.initSDK(appKey: KakaoAuthConfig.nativeAppKey)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
