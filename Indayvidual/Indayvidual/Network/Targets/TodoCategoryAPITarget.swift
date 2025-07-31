//
//  TodoCategoryAPITarget.swift
//  Indayvidual
//
//  Created by 김지민 on 7/28/25.
//

import Foundation
import Moya
import SwiftUI

enum TodoCategoryAPITarget {
    case getCategories //카테고리 조회
    case postCategories (name:String, color:String) //카테고리 등록
}

extension TodoCategoryAPITarget : APITargetType{
    var path : String {
        switch self{
        case .getCategories:
            return "/api/todo/categories"
        case .postCategories:
            return "/api/todo/categories"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCategories:
            return .get
        case .postCategories:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getCategories :
            return .requestPlain
        case .postCategories(let name, let color):
            let dto = CategoryRequestDTO(name: name, color: color)
            return .requestJSONEncodable(dto)
        }
    }
    
    var headers: [String : String]?{
        return ["Content-Type" : "application/json"]
    }
}
