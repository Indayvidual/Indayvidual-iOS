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
    case deleteCategory (categoryId : Int) //카테고리 삭제
    case updateCategory (categoryId : Int, name:String, color : String) //카테고리 수정
}

extension TodoCategoryAPITarget : APITargetType{
    var path : String {
        switch self{
        case .getCategories:
            return "/api/todo/categories"
        case .postCategories:
            return "/api/todo/categories"
        case .deleteCategory(let categoryId):
            return "/api/todo/categories/\(categoryId)"
        case .updateCategory(let categoryId, _, _) :
            return "/api/todo/categories/\(categoryId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCategories:
            return .get
        case .postCategories:
            return .post
        case .deleteCategory:
            return .delete
        case .updateCategory:
            return .patch
        }
    }
    
    var task: Task {
        switch self {
        case .getCategories :
            return .requestPlain
        case .postCategories(let name, let color):
            let dto = CategoryRequestDTO(name: name, color: color)
            return .requestJSONEncodable(dto)
        case .deleteCategory(_):
            return .requestPlain
        case .updateCategory(_, let name, let color):
            let dto = CategoryRequestDTO(name: name, color: color)
            return .requestJSONEncodable(dto)
        }
    }
    
    var headers: [String: String]? {
        var headers: [String: String] = [:]
        headers["Content-Type"] = "application/json"
        return headers
    }
}
