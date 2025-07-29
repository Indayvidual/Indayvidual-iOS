//
//  TimetableTarget.swift
//  Indayvidual
//
//  Created by 장주리 on 7/28/25.
//

import Foundation
import Moya

enum TimetableTarget {
    case postTimetable(content: TimetableRequestDto)
    case getTimetable
}

extension TimetableTarget: APITargetType{
    var path: String{
        switch self{
        case .postTimetable(_):
            return "/api/timetable"
        case .getTimetable:
            return "/api/timetable"
        }
    }
    
    var method: Moya.Method{
        switch self{
        case .postTimetable:
            return .post
        case .getTimetable:
            return .get
        }
    }
    
    var task: Task {
        switch self{
        case .postTimetable(let content):
            return .requestJSONEncodable(content)
        case .getTimetable:
            return .requestPlain
        }
    }
    
    var headers: [String : String]?{
        //TODO: 액세스 토큰 헤더 추가 (Authorization : Bearer <accessToken>)
        return ["Content-Type" : "application/json"]
    }
    
}
