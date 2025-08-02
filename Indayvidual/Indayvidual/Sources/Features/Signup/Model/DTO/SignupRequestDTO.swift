//
//  SignupRequestDTO.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/1/25.
//

import Foundation

struct SignupRequestDTO: Encodable {
    let email: String
    let password: String
    let nickname: String
}
