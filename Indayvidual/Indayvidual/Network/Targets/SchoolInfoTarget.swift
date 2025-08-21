//
//  SchoolInfoTarget.swift
//  Indayvidual
//
//  Created by 장주리 on 7/23/25.
//

import Moya
import Foundation

enum SchoolInfoTarget {
    case getSchoolInfo(apiKey: String, searchTxt: String)
}

/// 커리어넷 대학 리스트 오픈 API
extension SchoolInfoTarget: TargetType {
    var baseURL: URL { URL(string: "https://www.career.go.kr")! }
    var path: String { "/cnet/openapi/getOpenApi" }
    var method: Moya.Method { .get }
    
    var task: Task {
        switch self {
        case .getSchoolInfo(let apiKey, let searchTxt):
            var params: [String: Any] = [
                "apiKey": apiKey,
                "svcType": "api",
                "svcCode": "SCHOOL",
                "contentType": "json",
                "gubun": "univ_list",
                "perPage": 30
            ]
             if !searchTxt.isEmpty {
                 params["searchSchulNm"] = searchTxt
             }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? { ["Content-Type": "application/json"] }
    
}