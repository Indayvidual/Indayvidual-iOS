//
//  AuthResponse.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/2/25.
//

import Foundation

struct AuthResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: AuthData?
}

struct AuthData: Decodable {
    let accessToken: String
    let refreshToken: String
    let userId: Int
    let email: String
    let username: String
    let role: String

    enum CodingKeys: String, CodingKey {
        case accessToken, refreshToken, userId, email, username = "nickname", role
    }
}
