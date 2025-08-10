//
//  APIResponseDto.swift
//  Indayvidual
//
//  Created by 장주리 on 8/7/25.
//

import Foundation

struct APIResponseDto<T: Codable>: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: T
}
