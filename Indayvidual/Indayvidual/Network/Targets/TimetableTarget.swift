//
//  TimetableTarget.swift
//  Indayvidual
//
//  Created by 장주리 on 7/28/25.
//

import Foundation
import Moya

enum TimetableTarget {
    case postTimetable(schoolId: String, schoolName: String, semester: String, image: Data)
    case getTimetable
    case deleteTimetable(timetableId: Int)
}

extension TimetableTarget: APITargetType{
    var path: String{
        switch self{
        case .postTimetable:
            return "/api/timetable"
        case .getTimetable:
            return "/api/timetable"
        case .deleteTimetable(let titmetableId):
            return "/api/timetable/\(titmetableId)"
        }
    }
    
    var method: Moya.Method{
        switch self{
        case .postTimetable:
            return .post
        case .getTimetable:
            return .get
        case .deleteTimetable:
            return .delete
        }
    }
    
    var task: Task {
           switch self {
           case .postTimetable(let schoolId, let schoolName, let semester, let image):
               let formData = MultipartFormData(
                   provider: .data(image),
                   name: "image",
                   fileName: "timetable.jpg",
                   mimeType: "image/jpeg"
               )
               
               let params: [String: Any] = [
                   "schoolId": schoolId,
                   "schoolName" : schoolName,
                   "semester": semester
               ]
               
               return .uploadCompositeMultipart([formData], urlParameters: params)
               
           case .getTimetable:
               return .requestPlain
               
           case .deleteTimetable(_):
               return .requestPlain
           }
       }
    
    var headers: [String : String]? {
        var headers = [String: String]()
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken"), !accessToken.isEmpty {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        return headers
    }
}
