//
//  LoginResponseDTO.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/2/25.
//

import Foundation

struct LoginResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: TokenInfo
}

struct TokenInfo: Decodable {
    let accessToken: String
    let refreshToken: String
    let userId: Int
    let email: String
    let username: String?
    let role: String
}
