//
//  EventTarget.swift
//  Indayvidual
//
//  Created by 장주리 on 7/28/25.
//

import Foundation
import Moya

enum EventTarget{
    case postEvent(content: EventRequestDto)
    case deleteEvent(eventId: Int)
    case patchEvent(eventId: Int, content: EventRequestDto)
    case getEvents(date: String)
}

extension EventTarget: APITargetType{
    var path: String{
        switch self{
        case .postEvent:
            return "/api/events"
        case .deleteEvent(let eventId), .patchEvent(let eventId, _):
            return "/api/events/\(eventId)"
        case .getEvents:
            return "/api/events"
        }
    }
    
    var method: Moya.Method{
        switch self{
        case .postEvent:
            return .post
        case .deleteEvent:
            return .delete
        case .patchEvent:
            return .patch
        case .getEvents:
            return .get
        }
    }
    
    var task: Task{
        switch self{
        case .postEvent(let content), .patchEvent(_, let content):
            return .requestJSONEncodable(content)
            
        case .deleteEvent:
            return .requestPlain
            
        case .getEvents(let date):
            return .requestParameters(parameters: ["date": date], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]?{
        //TODO: 액세스 토큰 헤더 추가 (Authorization : Bearer <accessToken>)
        return ["Content-Type" : "application/json"]
    }
}
