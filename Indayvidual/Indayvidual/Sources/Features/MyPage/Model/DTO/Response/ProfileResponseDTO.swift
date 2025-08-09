//
//  MyProfileResponse.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/3/25.
//

import Foundation

struct ProfileResponseDTO: Decodable, Hashable {   // <- 그대로 유지 OK
    let isSuccess: Bool
    let code: String
    let message: String
    let data: ProfileDataOrMessage?
}

enum ProfileDataOrMessage: Decodable, Hashable {   // <- Hashable 추가
    case object(Profile)
    case message(String)

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let p = try? c.decode(Profile.self) {
            self = .object(p)
        } else if let s = try? c.decode(String.self) {
            self = .message(s)
        } else {
            self = .message("알 수 없는 응답 형식")
        }
    }
}

struct Profile: Decodable, Hashable {              // <- Hashable 추가
    let userId: Int
    let email: String
    let nickname: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case userId, email, imageUrl
        case nickname = "username"
    }
}
