//
//  HabitAPITarget.swift
//  Indayvidual
//
//  Created by 김도연 on 7/28/25.
//

import Foundation
import Moya

enum HabitAPITarget {
    case getHabits
    case postHabits(title: String, colorCode: String)
    case deleteHabits(habitId: Int)
    case patchHabits(habitId: Int, title: String, colorCode: String)
    case patchHabitsCheck(habitId: Int, date: String, checked: Bool)
    case getHabitsCheckDaily(Date: String)
    case getHabitsCheckWeekly(startDate: String)
    case getHabitsCheckMonthly(yearMonth: String)
}

extension HabitAPITarget: APITargetType {
    var path: String {
        switch self {
        case .getHabits, .postHabits:
            return "/api/custom/habits"
        case .deleteHabits(let habitId), .patchHabits(let habitId, _, _):
            return "/api/custom/habits/\(habitId)"
        case .patchHabitsCheck(let habitId, _, _):
            return "/api/custom/habits/\(habitId)/check"
        case .getHabitsCheckDaily(_):
            return "/api/custom/habits/checks/daily"
        case .getHabitsCheckWeekly(_):
            return "/api/custom/habits/checks/weekly"
        case .getHabitsCheckMonthly(_):
            return "/api/custom/habits/checks/monthly"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getHabits, .getHabitsCheckDaily, .getHabitsCheckWeekly, .getHabitsCheckMonthly:
            return .get
        case .patchHabits, .patchHabitsCheck:
            return .patch
        case .postHabits:
            return .post
        case .deleteHabits:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getHabits, .deleteHabits:
            return .requestPlain
            
        case .postHabits(let title, let colorCode):
            let parameters: [String: Any] = [
                "title": title,
                "colorCode": colorCode
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .patchHabits(_, let title, let colorCode):
            let parameters: [String: Any] = [
                "title": title,
                "colorCode": colorCode
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .patchHabitsCheck(_, let date, let checked):
            let parameters: [String: Any] = [
                "date": date,
                "checked": checked
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
                
        case .getHabitsCheckDaily(let date):
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
            
        case .getHabitsCheckWeekly(let startDate):
            return .requestParameters(parameters:
                ["startDate": startDate],
                encoding: URLEncoding.queryString
            )
            
        case .getHabitsCheckMonthly(yearMonth: let yearMonth) :
            return .requestParameters(parameters:
                ["yearMonth": yearMonth],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String : String]? {
        return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxNSIsImlhdCI6MTc1NDYxNTYxMSwiZXhwIjoxNzU0NjE2NTExLCJ1c2VySWQiOjE1LCJyb2xlIjoiUk9MRV9VU0VSIiwidG9rZW5UeXBlIjoiYWNjZXNzIn0.YATLyB6cCykMnj4ZrVkg9HLGwiSH2j0xmIB_eSb9jbg")"
            ]
    }

}
