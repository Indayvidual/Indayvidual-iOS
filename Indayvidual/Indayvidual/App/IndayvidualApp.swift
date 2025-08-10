//
//  IndayvidualApp.swift
//  Indayvidual
//
//  Created by 장주리 on 7/2/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct IndayvidualApp: App {
    @StateObject var userSession = UserSession()
    
    init() {
            let kakaoNativeAppKey = (Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String) ?? ""
            KakaoSDK.initSDK(appKey: kakaoNativeAppKey) 
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSession)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
