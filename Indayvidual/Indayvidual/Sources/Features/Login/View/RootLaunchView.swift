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
                }
            } else {
                ContentView()
            }
        }
    }
}


#Preview {
    RootLaunchView()
        .environmentObject(UserSession())
        .environmentObject(AlertService())
}
