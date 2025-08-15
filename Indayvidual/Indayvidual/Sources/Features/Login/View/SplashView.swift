//
//  SplashView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/15/25.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.gray50.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image("Indayvidual")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
}
