//
//  KakaoAuthService.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/10/25.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser

enum KakaoLoginError: Error { case noToken }

final class KakaoAuthService {
    static let shared = KakaoAuthService()
    private init() {}

    func getAccessToken() async throws -> String {
        let canUseTalk = UserApi.isKakaoTalkLoginAvailable()

        do {
            let token: KakaoSDKAuth.OAuthToken  // KakaoSDKAuth.OAuthToken으로 명시적 타입 사용

            if canUseTalk {
                // 카카오톡 로그인
                token = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<KakaoSDKAuth.OAuthToken, Error>) in
                    UserApi.shared.loginWithKakaoTalk { t, e in
                        if let e = e {
                            cont.resume(throwing: e)
                            return
                        }
                        guard let t = t else {
                            cont.resume(throwing: KakaoLoginError.noToken) // 토큰이 없으면 오류
                            return
                        }
                        cont.resume(returning: t) // 토큰 반환
                    }
                }
            } else {
                // 카카오 계정 로그인
                token = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<KakaoSDKAuth.OAuthToken, Error>) in
                    UserApi.shared.loginWithKakaoAccount { t, e in
                        if let e = e {
                            cont.resume(throwing: e) // 오류가 발생하면 오류를 던짐
                            return
                        }
                        guard let t = t else {
                            cont.resume(throwing: KakaoLoginError.noToken) // 토큰이 없으면 오류
                            return
                        }
                        cont.resume(returning: t) // 토큰 반환
                    }
                }
            }

            return token.accessToken // 액세스 토큰 반환
        } catch {
            // 카카오톡 로그인 실패 → 계정 로그인으로 재시도
            if canUseTalk {
                let token = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<KakaoSDKAuth.OAuthToken, Error>) in
                    UserApi.shared.loginWithKakaoAccount { t, e in
                        if let e = e {
                            cont.resume(throwing: e) // 오류가 발생하면 오류를 던짐
                            return
                        }
                        guard let t = t else {
                            cont.resume(throwing: KakaoLoginError.noToken) // 토큰이 없으면 오류
                            return
                        }
                        cont.resume(returning: t) // 토큰 반환
                    }
                }
                return token.accessToken // 계정 로그인 후 얻은 토큰 반환
            }
            throw error // 모든 시도 실패 시 오류 반환
        }
    }
}
