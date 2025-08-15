//
//  KakaoAuthService.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/10/25.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import UIKit

struct KakaoProfile {
    let nickname: String?
    let imageUrl: String?
}

enum KakaoLoginError: Error { case noToken, noProfile }

@MainActor
final class KakaoAuthService {
    static let shared = KakaoAuthService()
    private init() {}

    // 액세스 토큰 얻기
    func getAccessToken() async throws -> String {

        let canUseTalk = UserApi.isKakaoTalkLoginAvailable()
        do {
            let token: OAuthToken
            if canUseTalk {
                token = try await loginWithKakaoTalk()
            } else {
                token = try await loginWithKakaoAccount()
            }
            return token.accessToken
        } catch {
            if canUseTalk {
                let t = try await loginWithKakaoAccount()
                return t.accessToken
            }
            throw error
        }
    }

    // 프로필 요청 + 강제 에러 노출
    func fetchKakaoProfile() async throws -> KakaoProfile {
        return try await withCheckedThrowingContinuation { cont in
            UserApi.shared.me { user, error in
                if let error = error {
                    cont.resume(throwing: error); return
                }
                guard let p = user?.kakaoAccount?.profile else {
                    cont.resume(throwing: KakaoLoginError.noProfile); return
                }
                let prof = KakaoProfile(
                    nickname: p.nickname,
                    imageUrl: p.profileImageUrl?.absoluteString
                )
                cont.resume(returning: prof)
            }
        }
    }

    // MARK: - Private
    private func loginWithKakaoTalk() async throws -> OAuthToken {
        try await withCheckedThrowingContinuation { cont in
            UserApi.shared.loginWithKakaoTalk { t, e in
                if let e {
                    cont.resume(throwing: e); return
                }
                guard let t else { cont.resume(throwing: KakaoLoginError.noToken); return }
                cont.resume(returning: t)
            }
        }
    }
    private func loginWithKakaoAccount() async throws -> OAuthToken {
        try await withCheckedThrowingContinuation { cont in
            UserApi.shared.loginWithKakaoAccount { t, e in
                if let e {
                    cont.resume(throwing: e); return
                }
                guard let t else { cont.resume(throwing: KakaoLoginError.noToken); return }
                cont.resume(returning: t)
            }
        }
    }
    private func waitForActiveScene(timeout: TimeInterval = 3) async {
        func active() -> Bool {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .contains { $0.activationState == .foregroundActive }
        }
        if active() { return }
        let end = Date().addingTimeInterval(timeout)
        for await _ in NotificationCenter.default.notifications(named: UIScene.didActivateNotification) {
            if active() || Date() > end { break }
        }
    }
}
