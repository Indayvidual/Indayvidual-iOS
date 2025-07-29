//
//  TodoChecklistAPITarget.swift
//  Indayvidual
//
//  Created by 김지민 on 7/28/25.
//

import Foundation
import Moya
import SwiftUI

enum TodoChecklistAPITarget {
    case getTasks(categoryId : Int, date : String) //할 일 목록 조회
    case postTasks (categoryId: Int, title:String, date:String) //할 일 등록
    case patchTitle (taskId : Int, title:String) //할 일 제목 수정
    case patchDueDate (taskId:Int, date : String) //할 일 날짜 수정
    case patchCheck (taskId:Int, isCompleted : Bool) //할 일 체크 및 해제
    case patchOrder (categoryId:Int, taskOrder : [Int]) //할 일 순서 변경
    case deleteTasks (taskId:Int) // 할 일 삭제
}

extension TodoChecklistAPITarget : APITargetType{
    var path : String {
        switch self{
        case .getTasks(let categoryId, _):
            return "/api/todo/categories/\(categoryId)/tasks"
        case .postTasks(let categoryId, _, _):
            return "/api/todo/categories/\(categoryId)/tasks"
        case .patchTitle(let taskId, _):
            return "/api/todo/tasks/\(taskId)/title"
        case .patchDueDate(let taskId, _):
            return "/api/todo/tasks/\(taskId)/due-date"
        case .patchCheck(let taskId, _):
            return "/api/todo/tasks/\(taskId)/check"
        case .patchOrder(let categoryId, _):
            return "/api/todo/categories/\(categoryId)/tasks/order"
        case .deleteTasks(let taskId):
            return "/api/todo/tasks/\(taskId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTasks :
            return .get
        case .postTasks:
            return .post
        case .patchCheck, .patchOrder, .patchDueDate, .patchTitle :
            return .patch
        case .deleteTasks:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getTasks(_, let date) :
            return .requestParameters(parameters: ["date":date], encoding: URLEncoding.queryString)
        case .postTasks(_, let title, let date) :
            let dto = TaskCreateRequestDTO(title: title, date: date)
            return .requestJSONEncodable(dto)
        case .patchTitle(_, let title) :
            let dto = TaskUpdateTitleRequestDTO(title: title)
            return .requestJSONEncodable(dto)
        case .patchDueDate(_, let date) :
            let dto = TaskUpdateDateRequestDTO(date: date)
            return .requestJSONEncodable(dto)
        case .patchCheck(_, let isCompleted):
            let dto = TaskUpdateCheckRequestDTO(isCompleted: isCompleted)
            return .requestJSONEncodable(dto)
        case .patchOrder(_, let taskOrder):
            let dto = TaskUpdateOrderRequestDTO(taskOrder: taskOrder)
            return .requestJSONEncodable(dto)
        case .deleteTasks(_):
            return .requestPlain
        }
    }
    
    var headers: [String : String]?{
        return ["Content-Type" : "application/json"]
    }
}
