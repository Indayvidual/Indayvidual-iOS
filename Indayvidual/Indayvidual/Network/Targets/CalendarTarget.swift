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
            return "/api/calendar/home/\(year)/\(month)"
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
    
    var headers: [String : String]?{
        //TODO: 액세스 토큰 헤더 추가 (Authorization : Bearer <accessToken>)
        return ["Content-Type" : "application/json"]
    }
}
