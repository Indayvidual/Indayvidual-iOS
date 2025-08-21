//
//  RootLaunchView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/15/25.
//

import SwiftUI

struct RootLaunchView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashView {
                    showSplash = false
                    hydrateSessionIfNeeded()
                }
            } else {
                // 스플래시가 끝난 시점에 토큰 유무로 즉시 분기
                if userSession.accessToken.isEmpty || userSession.refreshToken.isEmpty {
                    LoginView()
                } else {
                    IndayvidualTabView()
                        .environmentObject(userSession)
                }
            }
        }
        .onAppear {
            // 앱 cold start 시에도 대비
            NetworkKit.configure(userSession: userSession)
            if !showSplash { hydrateSessionIfNeeded() }
        }
        .onReceive(userSession.$accessToken.combineLatest(userSession.$refreshToken)) { at, rt in
                    if at.isEmpty || rt.isEmpty {
                        showSplash = false
                    }
                }
    }
    
    private func hydrateSessionIfNeeded() {
        // 자동로그인 ON일 때만 저장된 토큰 복구, OFF면 항상 클리어
        if userSession.autoLogin {
            let at = UserDefaults.standard.string(forKey: "accessToken")  ?? ""
            let rt = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
            userSession.accessToken = at
            userSession.refreshToken = rt
        } else {
            userSession.clear()
        }
    }
}


#Preview {
    RootLaunchView()
        .environmentObject(UserSession())
        .environmentObject(AlertService())
}
