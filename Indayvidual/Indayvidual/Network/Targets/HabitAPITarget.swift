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
    case getHabitsCheckDaily(startDate: String)
    case getHabitsCheckWeekly(startDate: String)
    case getHabitsCheckMonthly(startDate: String)
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
        case .getHabitsCheckDaily(let startDate):
            return "/api/custom/habits/checks/daily"
        case .getHabitsCheckWeekly(let startDate):
            return "/api/custom/habits/checks/weekly"
        case .getHabitsCheckMonthly(let startDate):
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
            
        case .patchHabitsCheck(habitId: let habitId, let date, let checked):
            let parameters: [String: Any] = [
                "date": date,
                "checked": checked
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .getHabitsCheckDaily(let startDate), .getHabitsCheckWeekly(let startDate), .getHabitsCheckMonthly(let startDate):
            return .requestParameters(parameters: ["startDate": startDate], encoding: URLEncoding.queryString)
        }
    }
    

    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
