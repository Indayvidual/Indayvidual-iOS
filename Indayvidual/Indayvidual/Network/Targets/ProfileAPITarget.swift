//
//  ProfileAPITarget.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/3/25.
//

import Foundation
import Moya

enum ProfileAPITarget {
    case getMyProfile
    case updateNickname(nickname: String)
    case updatePassword(password: String)
    case verifyBeforeUpdate(currentPassword: String)  // Changed to match API requirement
    case updateProfileImage(imageData: Data)
    case deleteAccount
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
        case .getMyProfile:
            return "/api/mypage/profile"
        case .updateNickname:
            return "/api/mypage/update_username"
        case .updatePassword:
            return "/api/mypage/update_password"
        case .verifyBeforeUpdate:
            return "/api/auth/re-auth/password" // Ensure correct path for verifying password
        case .updateProfileImage:
            return "/api/mypage/profile-image"
        case .deleteAccount:
            return "/api/mypage/delete"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMyProfile:
            return .get
        case .updateNickname, .updatePassword, .updateProfileImage:
            return .patch
        case .verifyBeforeUpdate:
            return .post
        case .deleteAccount:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .getMyProfile, .deleteAccount:
            return .requestPlain

        case let .updateNickname(nickname):
            return .requestJSONEncodable(["nickname": nickname])

        case let .updatePassword(password):
            return .requestJSONEncodable(["password": password])

        case let .verifyBeforeUpdate(password):
            return .requestParameters(parameters: ["currentPassword": password],
                                      encoding: JSONEncoding.default)

        case let .updateProfileImage(imageData):
            let multipart = MultipartFormData(
                provider: .data(imageData),
                name: "profileImage",
                fileName: "profile.jpg",
                mimeType: "image/jpeg"
            )
            return .uploadMultipart([multipart])
        }
    }

    var headers: [String: String]? {

        var h: [String: String] = [
            "Accept": "application/json"
        ]

        // 인증 토큰
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken"),
           !accessToken.isEmpty {
            h["Authorization"] = "Bearer \(accessToken)"
        }

        // 엔드포인트별 분기
        switch self {
        case .getMyProfile:
            // 서버 요구: 프로필 조회는 X-Reauth-Token 필수
            if let rt = UserDefaults.standard.string(forKey: "reauthToken"),
               !rt.isEmpty {
                h["X-Reauth-Token"] = rt
            } else {
                #if DEBUG
                print("⚠️ Missing X-Reauth-Token for getMyProfile")
                #endif
            }
            // GET이지만 일부 서버가 Content-Type을 요구할 수 있어 JSON으로 맞춰줌
            h["Content-Type"] = "application/json"

        case .updateNickname, .updatePassword, .verifyBeforeUpdate, .deleteAccount:
            if let rt = UserDefaults.standard.string(forKey: "reauthToken"), !rt.isEmpty {
                h["X-Reauth-Token"] = rt
            }
            h["Content-Type"] = "application/json"

        case .updateProfileImage:
            break
        }

        return h
    }

}
