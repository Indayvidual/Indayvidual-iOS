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
    case verifyPassword(provider: String, password: String?)
    case kakaoReauth(kakaoAccessToken: String)
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
        case .verifyPassword: return "/api/auth/re-auth/password"
        case .kakaoReauth: return "/api/auth/re-auth/kakao"
        }
    }

    var method: Moya.Method {
        return .post
    }
    
    struct KakaoReauthBody: Encodable {
            let kakaoAccessToken: String
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
        case let .verifyPassword(provider, password):
                var params: [String: Any] = ["provider": provider]
                if let password = password {
                    params["password"] = password
                }
                return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .kakaoReauth(let at):
                    return .requestJSONEncodable(KakaoReauthBody(kakaoAccessToken: at))
        }
    }

    var headers: [String: String]? {
        switch self {
        case let .refresh(refreshToken):
            return [
                "Content-Type": "application/json",
                "Refresh-Token": refreshToken
            ]
            
        case .verifyPassword:
                    var headers = ["Content-Type": "application/json"]
                    if let token = UserDefaults.standard.string(forKey: "accessToken") {
                        headers["Authorization"] = "Bearer \(token)"
                    }
                    return headers
            
        case .kakaoReauth:
                    return ["Content-Type": "application/json"]
            
        default:
            return ["Content-Type": "application/json"]
        }
    }
}

