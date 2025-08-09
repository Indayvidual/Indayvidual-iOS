//
//  SignupAPITarget.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/1/25.
//

import Foundation
import Moya

enum SignupAPITarget {
    case checkEmail(email: String)
    case sendCode(email: String)
    case verifyCode(email: String, code: String)
    case signup(email: String, password: String, nickname: String, phoneNumber: String)
}

extension SignupAPITarget: TargetType {
    var baseURL: URL {
        if let baseURLString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
           let url = URL(string: baseURLString) {
            return url
        } else {
            fatalError("BASE_URL is missing or invalid in Info.plist")
        }
    }
    
    var path: String {
        switch self {
        case .checkEmail: return "/api/auth/email/check"
        case .sendCode: return "/api/auth/email/send"
        case .verifyCode: return "/api/auth/email/verify"
        case .signup: return "/api/auth/signup"
        }
    }

    var method: Moya.Method {
        switch self {
        case .checkEmail: return .get
        default: return .post
        }
    }

    var task: Task {
        switch self {
        case let .checkEmail(email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.queryString)
        case let .sendCode(email):
            return .requestJSONEncodable(["email": email])
        case let .verifyCode(email, code):
            return .requestJSONEncodable(["email": email, "code": code])
        case let .signup(email, password, nickname, phoneNumber):
            return .requestJSONEncodable(SignupRequestDTO(email: email, password: password, nickname: nickname, phoneNumber: phoneNumber))
        }
    }

    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
