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
    let result: AuthResult
}

struct AuthResult: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let isNewUser: Bool
}
