//
//  APIResponse.swift
//  Indayvidual
//
//  Created by 김지민 on 8/6/25.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: T
}

// data가 null일 때 대비
struct EmptyResult: Decodable {}
