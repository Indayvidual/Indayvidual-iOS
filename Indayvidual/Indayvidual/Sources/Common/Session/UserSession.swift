//
//  UserSession.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/2/25.
//

import Foundation

enum LoginProvider: String, Codable { case email, kakao }

class UserSession: ObservableObject {
    @Published var accessToken: String
    @Published var refreshToken: String
    @Published var userId: Int
    @Published var email: String = ""
    @Published var nickname: String = ""
    @Published var provider: LoginProvider = .email
    @Published var displayName: String = ""
    @Published var avatarURL: String? = nil

    init() {
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        self.refreshToken = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
        self.userId = UserDefaults.standard.integer(forKey: "userId")
        self.email = UserDefaults.standard.string(forKey: "email") ?? ""
        self.nickname = UserDefaults.standard.string(forKey: "nickname") ?? ""
        self.displayName = ""
        self.avatarURL = nil
    }

    func updateSession(token: TokenInfo) {
        accessToken = token.accessToken
        refreshToken = token.refreshToken
        userId = token.userId
        email = token.email
        nickname = token.nickname

        UserDefaults.standard.set(accessToken, forKey: "accessToken")
        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(nickname, forKey: "nickname")
    }

    func clear() {
        accessToken = ""
        refreshToken = ""
        userId = 0
        email = ""
        nickname = ""
        provider = .email
        displayName = ""
        avatarURL = nil

        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "nickname")
    }
}
