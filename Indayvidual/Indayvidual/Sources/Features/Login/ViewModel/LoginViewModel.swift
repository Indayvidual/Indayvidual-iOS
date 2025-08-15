//
//  LoginViewModel.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import Foundation
import UIKit
import Moya
import KakaoSDKUser
import AuthenticationServices

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var autoLogin: Bool = false
    @Published var isPasswordVisible: Bool = false
    @Published var isLoggingIn: Bool = false
    @Published var loginSuccess: Bool = false
    @Published var errorMessage: String?

    let provider = MoyaProvider<AuthAPITarget>()

    // 이메일 유효성 검사 계산된 프로퍼티
    var isValidEmail: Bool {
        guard !email.isEmpty else { return true }
        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    // 비밀번호 유효성 검사 계산된 프로퍼티
    var isValidPassword: Bool {
        guard !password.isEmpty else { return true }
        return password.count >= 6
    }

    // 로그인
    func login(userSession: UserSession) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "이메일과 비밀번호를 모두 입력해주세요."
            return
        }

        provider.request(.login(email: email, password: password)) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponseDTO.self, from: response.data)
                    guard loginResponse.isSuccess else {
                        self?.errorMessage = loginResponse.message
                        return
                    }

                    guard let token = loginResponse.data else {
                        self?.errorMessage = "토큰을 받을 수 없습니다."
                        return
                    }

                    let nameToShow = loginResponse.data?.nickname
                    userSession.updateSession(token: token)
                    userSession.provider = .email
                    userSession.displayName = nameToShow ?? ""
                    UserDefaults.standard.set(nameToShow, forKey: "nickname")
                    userSession.avatarURL = nil
                    
                    DispatchQueue.main.async {
                        self?.loginSuccess = true
                    }
                } catch {
                    self?.errorMessage = "디코딩 실패: \(error.localizedDescription)"
                }

            case .failure(let error):
                self?.errorMessage = "로그인 실패: \(error.localizedDescription)"
            }
        }
    }

    func loginWithKakaoToken(userSession: UserSession, onSuccess: (() -> Void)? = nil) async {
        isLoggingIn = true
        do {
            // 1) 카카오 SDK 토큰
            let kakaoAT = try await KakaoAuthService.shared.getAccessToken()

            // 2) /api/auth/kakao 호출을 async로 래핑
            let response: Response = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Response, Error>) in
                provider.request(.kakaoLogin(accessToken: kakaoAT)) { result in
                    switch result {
                    case .success(let r): cont.resume(returning: r)
                    case .failure(let e): cont.resume(throwing: e)
                    }
                }
            }

            // 3) 디코드
            let kakaoResp = try JSONDecoder().decode(KakaoLoginResponseDTO.self, from: response.data)
            guard kakaoResp.isSuccess, let data = kakaoResp.data else {
                await MainActor.run {
                    self.isLoggingIn = false
                    self.errorMessage = kakaoResp.message
                }
                return
            }

            // 4) 카카오 프로필 (async)
            let profile = try await KakaoAuthService.shared.fetchKakaoProfile()

            // 5) 메인에서 세션/캐시 반영
            await MainActor.run {
                userSession.accessToken  = data.accessToken
                userSession.refreshToken = data.refreshToken
                userSession.userId       = data.userId
                userSession.email        = data.email ?? ""
                userSession.provider     = .kakao
                userSession.displayName  = data.username ?? profile.nickname ?? ""
                userSession.avatarURL    = profile.imageUrl

                let nameToShow = data.username ?? profile.nickname ?? ""
                UserDefaults.standard.set(nameToShow, forKey: "nickname")
                UserDefaults.standard.set(profile.imageUrl, forKey: "avatarURL")
                UserDefaults.standard.set(data.accessToken,  forKey: "accessToken")
                UserDefaults.standard.set(data.refreshToken, forKey: "refreshToken")
                
                self.isLoggingIn = false
                self.loginSuccess = true
                onSuccess?()
            }
        } catch {
            await MainActor.run {
                self.isLoggingIn = false
                self.errorMessage = "카카오 로그인 실패: \(error.localizedDescription)"
            }
        }
    }

    
    func loginWithKakao(userSession: UserSession) async {
            await loginWithKakaoToken(userSession: userSession)
        }

    // 로그아웃
    func logout(userSession: UserSession) {
        provider.request(.logout) { result in
            UserApi.shared.logout { _ in }
            userSession.clear()
            UserDefaults.standard.removeObject(forKey: "refreshToken")
            print("🧹 로컬 토큰 삭제 완료")

            UserDefaults.standard.removeObject(forKey: "displayName")
                    UserDefaults.standard.removeObject(forKey: "avatarURL")
        }
    }
}
