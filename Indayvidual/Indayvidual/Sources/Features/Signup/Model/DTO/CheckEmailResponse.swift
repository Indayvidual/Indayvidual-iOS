//
//  CheckEmailResponsse.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/4/25.
//

import Foundation

struct CheckEmailResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
}
