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
        if userSession.accessToken.isEmpty {
            LoginView()
        } else {
            IndayvidualTabView()
        }
    }
}

#Preview {
    ContentView()
            .environmentObject(UserSession())
}
