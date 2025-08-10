//
//  ContentView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/2/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        if userSession.accessToken.isEmpty || userSession.refreshToken.isEmpty {
            LoginView()
        } else {
            IndayvidualTabView()
                .environmentObject(userSession)
        }
    }
}

#Preview {
    ContentView()
            .environmentObject(UserSession())
}
