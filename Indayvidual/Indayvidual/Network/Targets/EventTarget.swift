//
//  EventTarget.swift
//  Indayvidual
//
//  Created by 장주리 on 7/28/25.
//

import Foundation
import Moya

enum EventTarget{
    case postEvent(content: EventCreateRequestDto)
    case deleteEvent(eventId: Int)
    case patchEvent(eventId: Int, content: EventUpdateRequestDto)
    case getEvents(date: String)
}

extension EventTarget: APITargetType{
    var path: String{
        switch self{
        case .postEvent:
            return "/api/events"
        case .deleteEvent(let eventId), .patchEvent(let eventId, _):
            return "/api/events/\(eventId)"
        case .getEvents(let date):
            return "/api/events/\(date)"
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
        case .postEvent(let content):
            return .requestJSONEncodable(content)
            
        case .patchEvent(_, let content):
            return .requestJSONEncodable(content)
            
        case .deleteEvent, .getEvents:
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
