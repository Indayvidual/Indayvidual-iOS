//
//  CalendarTarget.swift
//  Indayvidual
//
//  Created by 장주리 on 7/28/25.
//

import Foundation
import Moya

enum CalendarTarget  {
    case getHomeCalendar(year: Int, month: Int)
}

extension CalendarTarget: APITargetType{
    var path: String{
        switch self{
        case .getHomeCalendar(let year, let month):
            return "/api/calendar/\(year)/\(month)"
        }
    }
    
    var method: Moya.Method {
        switch self{
        case .getHomeCalendar:
            return .get
        }
    }
    
    var task: Task{
        switch self{
        case .getHomeCalendar:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        var headers = ["Content-Type" : "application/json"]

        if let accessToken = UserDefaults.standard.string(forKey: "accessToken"), !accessToken.isEmpty {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return headers
    }
}
