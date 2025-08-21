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
    @StateObject private var alertService = AlertService()
    
    init() {
        let kakaoNativeAppKey = (Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String) ?? ""
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
    }
    
    var body: some Scene {
        
        WindowGroup {
            RootLaunchView()
                .rootAlert()
                .environmentObject(userSession)
                .environmentObject(alertService)
                .task {
                    NetworkKit.configure(userSession: userSession)
                }
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }

}
