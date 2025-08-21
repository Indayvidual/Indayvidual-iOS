//
//  ProfileAPITarget.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/3/25.
//

import Foundation
import Moya

private struct KakaoReauthBody: Encodable {
    let kakaoAccessToken: String
}

enum ProfileAPITarget {
    // 마이페이지
    case getMyProfile
    case checkUsername(username: String)
    case updateUsername(username: String)
    case updatePassword(currentPassword: String, newPassword: String)
    case uploadProfileImage(data: Data, fileName: String, mimeType: String)
    
    // 재인증
    case reauthPassword(currentPassword: String)
    case reauthKakao(kakaoAccessToken: String)

    // 탈퇴
    case deleteAccount(hard: Bool)
}

extension ProfileAPITarget: TargetType {
    var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("❌ BASE_URL is missing or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .getMyProfile: return "/api/mypage/profile"
        case .checkUsername: return "/api/mypage/username/check"
        case .updateUsername: return "/api/mypage/update_username"
        case .updatePassword: return "/api/mypage/update_password"
        case .uploadProfileImage: return "/api/mypage/profile-image"
        case .reauthPassword: return "/api/auth/re-auth/password"
        case .reauthKakao: return "/api/auth/re-auth/kakao"
        case .deleteAccount: return "/api/mypage/delete"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMyProfile, .checkUsername: return .get
        case .updateUsername, .updatePassword, .uploadProfileImage: return .patch
        case .reauthPassword, .reauthKakao: return .post
        case .deleteAccount: return .delete
        }
    }

    var task: Task {
        switch self {
        case .getMyProfile:
            return .requestPlain

        case let .checkUsername(username):
            return .requestParameters(parameters: ["username": username],
                                      encoding: URLEncoding.queryString)

        case let .updateUsername(username):
            return .requestJSONEncodable(["username": username])

        case let .updatePassword(currentPassword, newPassword):
            return .requestJSONEncodable([
                "currentPassword": currentPassword,
                "newPassword": newPassword
            ])

        case let .uploadProfileImage(data, fileName, mimeType):
            let part = MultipartFormData(provider: .data(data),
                                         name: "image",
                                         fileName: fileName,
                                         mimeType: mimeType)
            return .uploadMultipart([part])

        case let .reauthPassword(currentPassword):
            return .requestJSONEncodable(["currentPassword": currentPassword])

        case let .reauthKakao(kakaoAccessToken):
            return .requestJSONEncodable(KakaoReauthBody(kakaoAccessToken: kakaoAccessToken))

        case let .deleteAccount(hard):
            return .requestParameters(parameters: ["hard": hard], encoding: JSONEncoding.default)
        }
    }

    var headers: [String : String]? {
        var h: [String: String] = ["Accept": "*/*"]

        switch self {
        case .uploadProfileImage:
            // multipart는 Moya가 Content-Type을 자동으로 붙임
            break
        default:
            h["Content-Type"] = "application/json"
        }

        // 재인증 필요한 엔드포인트만 X-Reauth-Token 추가
        let needsReauth: Bool = {
            switch self {
            case .updateUsername, .updatePassword, .uploadProfileImage, .deleteAccount:
                return true
            default:
                return false
            }
        }()
        if needsReauth, let rt = UserDefaults.standard.string(forKey: "reauthToken"), !rt.isEmpty {
            h["X-Reauth-Token"] = rt
        }

        return h
    }

    var sampleData: Data { Data() }
}
