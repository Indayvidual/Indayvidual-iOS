//
//  IndayvidualApp.swift
//  Indayvidual
//
//  Created by 장주리 on 7/2/25.
//

import SwiftUI

@main
struct IndayvidualApp: App {
    @StateObject var userSession = UserSession()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSession)
        }
    }
}
