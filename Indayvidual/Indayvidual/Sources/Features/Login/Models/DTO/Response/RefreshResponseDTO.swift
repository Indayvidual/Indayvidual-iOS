//
//  RefreshResponseDTO.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/21/25.
//

struct ResponseBodyDTO<T: Decodable>: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: T?
}

// 리프레시 전용 data 모델
struct ReissueModel: Decodable {
    let accessToken: String
    let refreshToken: String
}

// 타입 별칭 (편의용)
typealias RefreshResponseDTO = ResponseBodyDTO<ReissueModel>
