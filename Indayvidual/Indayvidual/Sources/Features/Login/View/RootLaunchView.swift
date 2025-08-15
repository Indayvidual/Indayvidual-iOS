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
                SplashView()
            } else {
                // 기존 ContentView 그대로 사용 (토큰에 따라 로그인/탭뷰 분기)
                ContentView()
            }
        }
        .onAppear {
            // 1.5초 뒤 스플래시 종료
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    RootLaunchView()
}
