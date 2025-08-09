//
//  IndayvidualApp.swift
//  Indayvidual
//
//  Created by 장주리 on 7/2/25.
//

import SwiftUI

@main
struct IndayvidualApp: App {
    @StateObject private var alertService = AlertService()

    var body: some Scene {
        WindowGroup {
            IndayvidualTabView()
                .rootAlert()
        }
        .environmentObject(alertService)
    }
}
