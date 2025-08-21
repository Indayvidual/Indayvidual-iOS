//
//  ChangePassword.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/19/25.
//

import Foundation

struct ChangePasswordRequestDTO: Encodable {
    let currentPassword: String
    let newPassword: String
}

struct CommonResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
}
