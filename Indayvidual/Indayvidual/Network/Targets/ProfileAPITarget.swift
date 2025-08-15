//
//  ProfileAPITarget.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/3/25.
//

import Foundation
import Moya

// 재인증용 바디
private struct KakaoReauthBody: Encodable {
    let kakaoAccessToken: String
}

enum ProfileAPITarget {
    // 마이페이지
    case getMyProfile
    case updateNickname(nickname: String)
    case updatePassword(newPassword: String)
    case updateProfileImage(imageData: Data)

    // 재인증
    case reauthPassword(currentPassword: String)
    case reauthKakao(kakaoAccessToken: String)

    // 탈퇴
    case deleteAccount(hard: Bool)
}

extension ProfileAPITarget: TargetType {
    // MARK: - Base URL
    var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("❌ BASE_URL is missing or invalid in Info.plist")
        }
        return url
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .getMyProfile:              return "/api/mypage/profile"
        case .updateNickname:            return "/api/mypage/update_username"
        case .updatePassword:            return "/api/mypage/update_password"
        case .updateProfileImage:        return "/api/mypage/profile-image"

        case .reauthPassword:            return "/api/auth/re-auth/password"
        case .reauthKakao:               return "/api/auth/re-auth/kakao"

        case .deleteAccount:             return "/api/mypage/delete"
        }
    }

    // MARK: - Method
    var method: Moya.Method {
        switch self {
        case .getMyProfile:              return .get
        case .updateNickname,
             .updatePassword,
             .updateProfileImage:        return .patch

        case .reauthPassword,
             .reauthKakao:               return .post

        case .deleteAccount:             return .delete
        }
    }

    // MARK: - Task
    var task: Task {
        switch self {
        case .getMyProfile:
            return .requestPlain

        case let .updateNickname(nickname):
            return .requestJSONEncodable(["nickname": nickname])

        case let .updatePassword(newPassword):
            // 서버 스펙에 맞게 키 이름 확인 (예: "password" or "newPassword")
            return .requestJSONEncodable(["password": newPassword])

        case let .updateProfileImage(imageData):
            // multipart/form-data (Moya가 Content-Type 자동 설정)
            let part = MultipartFormData(
                provider: .data(imageData),
                name: "profileImage",
                fileName: "profile.jpg",
                mimeType: "image/jpeg"
            )
            return .uploadMultipart([part])

        case let .reauthPassword(currentPassword):
            return .requestParameters(
                            parameters: ["currentPassword": currentPassword],
                            encoding: JSONEncoding.default
                        )

        case let .reauthKakao(kakaoAccessToken):
            return .requestJSONEncodable(KakaoReauthBody(kakaoAccessToken: kakaoAccessToken))

        case let .deleteAccount(hard):
            // DELETE with JSON body { "hard": Bool }
            return .requestParameters(parameters: ["hard": hard],
                                      encoding: JSONEncoding.default)
        }
    }

    // MARK: - Headers
    var headers: [String: String]? {
        // 공통
        var h: [String: String] = [:]

        // Authorization (필요 시)
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken"),
           !accessToken.isEmpty {
            h["Authorization"] = "Bearer \(accessToken)"
        }

        // Reauth가 필요한 엔드포인트에만 X-Reauth-Token 부착
        let needsReauth: Bool = {
            switch self {
            case .updateNickname,
                 .updatePassword,
                 .updateProfileImage,
                 .deleteAccount:
                return true
            case .getMyProfile,
                    .reauthPassword, .reauthKakao:
                return false
            }
        }()

        if needsReauth {
            if let rt = UserDefaults.standard.string(forKey: "reauthToken"),
               !rt.isEmpty {
                h["X-Reauth-Token"] = rt
            } else {
#if DEBUG
                print("⚠️ Missing X-Reauth-Token for \(self)")
#endif
            }
        }

        // Content-Type
        switch self {
        case .updateProfileImage:
            // multipart/form-data는 Moya가 자동으로 설정하므로 지정하지 않음
            break
        default:
            h["Content-Type"] = "application/json"
            h["Accept"] = "*/*"
        }

        return h
    }

    // MARK: - Sample
    var sampleData: Data { Data() }
}
