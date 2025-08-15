//
//  SplashBackgroundView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/15/25.
//

import SwiftUI

struct SplashBackgroundView: View {
    var body: some View {
        Image("splash4")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

#Preview {
    SplashBackgroundView()
}
