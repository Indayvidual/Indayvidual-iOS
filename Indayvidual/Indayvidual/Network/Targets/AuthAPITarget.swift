//
//  AuthAPITarget.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/2/25.
//

import Foundation
import Moya

enum AuthAPITarget {
    case login(email: String, password: String)
    case kakaoLogin(accessToken: String)
    case refresh(refreshToken: String)
    case logout
    case deleteAccount(hard: Bool)
}

extension AuthAPITarget: TargetType {
    var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("❌ BASE_URL is missing or invalid in Info.plist")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .login: return "/api/auth/login"
        case .kakaoLogin: return "/api/auth/kakao"
        case .refresh: return "/api/auth/refresh"
        case .logout: return "/api/auth/logout"
        case .deleteAccount: return "/api/mypage/delete"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var headers: [String: String]? {
        switch self {
        case let .refresh(refreshToken):
            return [
                "Content-Type": "application/json",
                "Refresh-Token": refreshToken
            ]
            
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    var task: Task {
        switch self {
        case .login(email: let email, password: let password):
            return .requestJSONEncodable(LoginRequestDTO(email: email, password: password))
        case let .kakaoLogin(accessToken):
            return .requestJSONEncodable(["accessToken": accessToken])
        case let .refresh(refreshToken):
            return .requestJSONEncodable(["refreshToken": refreshToken])
        case .logout:
            return .requestPlain
        case let .deleteAccount(hard):
            return .requestParameters(parameters: ["hard": hard], encoding: JSONEncoding.default)
        }
    }
}
