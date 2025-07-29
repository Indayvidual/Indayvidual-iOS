//
//  CategoryResponseDTO.swift
//  Indayvidual
//
//  Created by 김지민 on 7/28/25.
//

import Foundation

struct CategoryResponseDTO: Decodable {
    let categoryId: Int
    let name: String
    let color: String
}
