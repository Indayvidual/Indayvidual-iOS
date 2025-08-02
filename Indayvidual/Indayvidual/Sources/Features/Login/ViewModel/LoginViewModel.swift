//
//  LoginViewModel.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import Foundation
import Moya

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
                            print("🔍 Raw JSON: ", String(data: response.data, encoding: .utf8) ?? "변환 실패")

                            let loginResponse = try JSONDecoder().decode(LoginResponseDTO.self, from: response.data)

                            guard loginResponse.isSuccess else {
                                self?.errorMessage = loginResponse.message
                                return
                            }

                            let token = loginResponse.data
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
    
    
    func refreshToken(_ token: String, completion: @escaping (Bool) -> Void) {
        provider.request(.refresh(refreshToken: token)) { result in
            switch result {
            case .success(let response):
                let success = response.statusCode == 200
                print(success ? "🔁 토큰 갱신 성공" : "❌ 토큰 갱신 실패")
                completion(success)
            case .failure(let error):
                print("❌ 토큰 갱신 네트워크 실패: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func logout() {
        provider.request(.logout) { result in
            switch result {
            case .success(let response):
                print("✅ 로그아웃 성공: \(response.statusCode)")
            case .failure(let error):
                print("❌ 로그아웃 실패: \(error.localizedDescription)")
            }
        }
    }
}


