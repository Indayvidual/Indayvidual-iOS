//
//  KakaoReauthResponseDTO.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/15/25.
//

import Foundation

struct KakaoReauthResponseDTO: Decodable {
    let isSuccess: Bool
    let message: String
    let data: KakaoReauthData?
}
struct KakaoReauthData: Decodable {
    let reauthToken: String
    let expiresInSeconds: Int
}
