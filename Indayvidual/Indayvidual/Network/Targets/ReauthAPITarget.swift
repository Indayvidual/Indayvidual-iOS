//
//  ReauthAPITarget.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/15/25.
//

import Foundation
import Moya

enum ReauthAPITarget {
    case password(currentPassword: String)
    case kakao(kakaoAccessToken: String)
}

extension ReauthAPITarget: TargetType {
    var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("❌ BASE_URL is missing or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .password: return "/api/auth/re-auth/password"
        case .kakao:    return "/api/auth/re-auth/kakao"
        }
    }

    var method: Moya.Method { .post }

    var task: Task {
        switch self {
        case .password(let pw):
            return .requestParameters(
                parameters: ["currentPassword": pw],
                encoding: JSONEncoding.default
            )
        case .kakao(let kakaoToken):
            return .requestParameters(
                parameters: ["kakaoAccessToken": kakaoToken],
                encoding: JSONEncoding.default
            )
        }
    }

    var headers: [String : String]? {
        ["Content-Type": "application/json", "Accept": "*/*"]
    }
}
