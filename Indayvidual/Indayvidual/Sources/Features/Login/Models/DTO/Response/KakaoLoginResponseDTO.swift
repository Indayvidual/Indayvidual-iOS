//
//  KakaoLoginResponseDTO.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/10/25.
//

import Foundation

struct KakaoLoginResponseDTO: Decodable {
    struct DataPart: Decodable {
        let accessToken: String
        let refreshToken: String
        let userId: Int
        let email: String?
        let username: String?
        let role: String?
        
        enum CodingKeys: String, CodingKey {
            case accessToken, refreshToken, userId, email, username = "nickname", role
        }
    }
    let isSuccess: Bool
    let code: String
    let message: String
    let data: DataPart?
}
