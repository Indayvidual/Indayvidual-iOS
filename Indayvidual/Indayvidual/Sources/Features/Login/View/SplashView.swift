//
//  SplashView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/15/25.
//

import SwiftUI

struct SplashView: View {
    /// 배경까지 보여준 뒤 로그인으로 넘어가라고 알려줄 콜백
    var onFinished: (() -> Void)?

    @State private var scale: CGFloat = 0.3
    @State private var rotation: Double = 0
    @State private var showBackground = false   // ← 추가

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if showBackground {
                // 2) 최종 배경
                SplashBackgroundView()
                    .transition(.opacity)
            } else {
                // 1) 로고 애니메이션(splash3)
                Image("splash3")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .onAppear {
            // 확대
            withAnimation(.easeOut(duration: 0.8)) { scale = 1.0 }
            // 회전
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 0.6)) { rotation = 45 }
            }
            // 배경으로 페이드 전환
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeIn(duration: 0.45)) { showBackground = true }
            }
            // 배경 잠깐 유지 후 종료 콜백 (여기서 로그인으로 이동)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
                onFinished?()
            }
        }
    }
}

#Preview { SplashView() }
