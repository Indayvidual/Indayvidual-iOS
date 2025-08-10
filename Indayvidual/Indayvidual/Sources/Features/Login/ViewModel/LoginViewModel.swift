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

                    userSession.updateSession(token: token)
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

            do {
                let kakaoAT = try await KakaoAuthService.shared.getAccessToken()

                provider.request(.kakaoLogin(accessToken: kakaoAT)) { [weak self] result in
                    guard let self = self else { return }
                    self.isLoggingIn = false

                    switch result {
                    case .success(let response):
                        do {
                            let kakaoResp = try JSONDecoder().decode(KakaoLoginResponseDTO.self, from: response.data)
                            guard kakaoResp.isSuccess, let data = kakaoResp.data else {
                                self.errorMessage = kakaoResp.message
                                return
                            }

                            let tokenInfo = TokenInfo(
                                accessToken: data.accessToken,
                                refreshToken: data.refreshToken,
                                userId: data.userId,
                                email: data.email ?? "",
                                nickname: data.username ?? "",
                                role: data.role ?? ""
                            )
                            userSession.updateSession(token: tokenInfo)

                            self.loginSuccess = true
                            onSuccess?()  // 로그인 성공 후 네비게이션 처리
                        } catch {
                            self.errorMessage = "디코딩 실패: \(error.localizedDescription)"
                        }

                    case .failure(let error):
                        self.errorMessage = "카카오 로그인 실패: \(error.localizedDescription)"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoggingIn = false
                    self.errorMessage = "카카오 인증 실패: \(error.localizedDescription)"
                }
            }
        }
    
    func loginWithKakao() {
            let clientId = (Bundle.main.infoDictionary?["KAKAO_REST_API_KEY"] as? String) ?? ""
            let redirectUri = "kakao763c58aead41a5eee8261f4761f38625://oauth"
            let authURL = "https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=\(clientId)&redirect_uri=\(redirectUri)"

            // 카카오 로그인 URL로 리디렉션
            if let url = URL(string: authURL) {
                UIApplication.shared.open(url)
            }
        }

    // 로그아웃
    func logout(userSession: UserSession) {
        provider.request(.logout) { result in
            switch result {
            case .success(let response):
                print("✅ 서버 로그아웃 성공: \(response.statusCode)")
            case .failure(let error):
                print("❌ 서버 로그아웃 실패: \(error.localizedDescription)")
            }

            userSession.clear()
            UserDefaults.standard.removeObject(forKey: "refreshToken")
            print("🧹 로컬 토큰 삭제 완료")

            DispatchQueue.main.async {
                // 로그인 화면으로 이동 등의 작업
            }
        }
    }
}
