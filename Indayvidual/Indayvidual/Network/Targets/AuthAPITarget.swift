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
    case kakaoLogin(authorizationCode: String)
    case refresh(refreshToken: String)
    case logout
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
        }
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case .login(email: let email, password: let password):
            return .requestJSONEncodable(LoginRequestDTO(email: email, password: password))
        case let .kakaoLogin(authorizationCode):
            return .requestJSONEncodable(["authorizationCode": authorizationCode])
        case let .refresh(refreshToken):
            return .requestJSONEncodable(["refreshToken": refreshToken])
        case .logout:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case let .refresh(refreshToken):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(refreshToken)"
            ]
        default:
            return ["Content-Type": "application/json"]
        }
    }
}
