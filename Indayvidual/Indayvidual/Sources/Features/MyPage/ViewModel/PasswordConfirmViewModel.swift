//
//  PasswordConfirmViewModel.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/3/25.
//

import Foundation
import Moya

final class PasswordConfirmViewModel: ObservableObject {
    private let provider = MoyaProvider<ProfileAPITarget>()

    /// 재인증 토큰 발급 (서버 요구 키는 currentPassword)
    func requestReauthToken(password: String, completion: @escaping (Bool) -> Void) {
        provider.request(.verifyBeforeUpdate(currentPassword: password)) { result in
            switch result {
            case .success(let response):
                print("📁 reauth 응답 코드:", response.statusCode)

                guard response.statusCode == 200 else {
                    print("❌ 재인증 실패:", String(data: response.data, encoding: .utf8) ?? "")
                    completion(false); return
                }

                do {
                    let decoded = try JSONDecoder().decode(ReauthResponse.self, from: response.data)
                    if decoded.isSuccess {
                        let token = decoded.data.reauthToken
                        let exp = Date().addingTimeInterval(TimeInterval(decoded.data.expiresInSeconds))
                        UserDefaults.standard.set(token, forKey: "reauthToken")
                        UserDefaults.standard.set(exp.timeIntervalSince1970, forKey: "reauthTokenExp")
                        print("✅ reauthToken 저장:", token)

                        // 필요하면 알림 유지(선택)
                        NotificationCenter.default.post(name: Notification.Name("reauthDidSucceed"), object: nil)
                        completion(true)
                    } else {
                        print("❌ 재인증 실패:", decoded.message)
                        completion(false)
                    }
                } catch {
                    print("❌ 재인증 디코딩 실패:", error)
                    completion(false)
                }

            case .failure(let error):
                print("❌ 네트워크 실패:", error)
                completion(false)
            }
        }
    }

    /// 비밀번호 검증 → 재인증 성공 → 프로필 조회 → Profile 반환
    /// (화면에서는 이 Profile을 EditProfileView로 넘겨 초기값 세팅)
    func verifyPassword(_ password: String, completion: @escaping (Profile?) -> Void) {
        requestReauthToken(password: password) { [weak self] ok in
            guard let self, ok else { completion(nil); return }
            self.fetchUserProfile { profile in
                completion(profile)
            }
        }
    }

    private func fetchUserProfile(completion: @escaping (Profile?) -> Void) {
        provider.request(.getMyProfile) { result in
            switch result {
            case .success(let response):
                print("📡 profile status:", response.statusCode)
                print("📦 body:", String(data: response.data, encoding: .utf8) ?? "nil")

                guard !response.data.isEmpty else {
                    completion(nil); return
                }

                do {
                    let dto = try JSONDecoder().decode(ProfileResponseDTO.self, from: response.data)

                    if case let .message(msg)? = dto.data, msg.contains("재인증") {
                        // 방금 재인증했는데 또 이런 메시지가 오면 헤더/토큰 전달 문제 가능
                        completion(nil); return
                    }

                    guard dto.isSuccess else {
                        completion(nil); return
                    }

                    if case let .object(p)? = dto.data {
                        completion(p)
                    } else {
                        completion(nil)
                    }
                } catch {
                    print("❌ 디코딩 실패:", error)
                    completion(nil)
                }

            case .failure(let error):
                print("❌ 네트워크 실패:", error)
                completion(nil)
            }
        }
    }
}

// 재인증 응답 DTO
struct ReauthResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let data: ReauthData
}
struct ReauthData: Decodable {
    let reauthToken: String
    let expiresInSeconds: Int
}
