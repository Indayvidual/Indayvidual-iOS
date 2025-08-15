//
//  SplashBackgroundView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/15/25.
//

import SwiftUI

struct SplashBackgroundView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 배경
            Image("splashbg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // 텍스트 + 아이콘
            VStack(alignment: .leading, spacing: 20) {
                Spacer().frame(height: 88)

                Text("Indayvidual")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.black)

                VStack(alignment: .leading, spacing: 6) {
                    Text("인데이비주얼과 함께")
                    Text("나만의 하루를 설계하기")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.black.opacity(0.85))

                // 하단 아이콘
                Image("Indayvidual")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
            }
            .padding(.horizontal, 28)
            .padding(.top, 52)
        }
    }
}

#Preview {
    SplashBackgroundView()
}
