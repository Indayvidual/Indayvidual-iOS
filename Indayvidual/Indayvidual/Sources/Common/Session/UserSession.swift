//
//  UserSession.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/2/25.
//

import Foundation

class UserSession: ObservableObject {
    @Published var accessToken: String
    @Published var refreshToken: String
    @Published var userId: Int
    @Published var email: String

    init() {
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        self.refreshToken = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
        self.userId = UserDefaults.standard.integer(forKey: "userId")
        self.email = UserDefaults.standard.string(forKey: "email") ?? ""
    }

    func updateSession(token: TokenInfo) {
        accessToken = token.accessToken
        refreshToken = token.refreshToken
        userId = token.userId
        email = token.email

        UserDefaults.standard.set(accessToken, forKey: "accessToken")
        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(email, forKey: "email")
    }

    func clear() {
        accessToken = ""
        refreshToken = ""
        userId = 0
        email = ""

        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "email")
    }
}
