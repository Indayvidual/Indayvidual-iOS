//
//  LoginViewModel.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var autoLogin: Bool = false
    @Published var isPasswordVisible: Bool = false
    @Published var isLoggingIn: Bool = false
    @Published var loginSuccess: Bool = false
    @Published var errorMessage: String?

    // 이메일 유효성 검사 계산된 프로퍼티
    var isValidEmail: Bool {
        guard !email.isEmpty else { return true }  // 이메일이 비어 있으면 에러 표시 안함
        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    // 비밀번호 유효성 검사 계산된 프로퍼티
    var isValidPassword: Bool {
        guard !password.isEmpty else { return true } // 비밀번호가 비어 있으면 에러 표시 안함
        return password.count >= 6  // 최소 6자리 비밀번호 조건
    }

    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "이메일과 비밀번호를 입력해주세요."
            return
        }

        isLoggingIn = true
        errorMessage = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoggingIn = false
            if self.email == "test@example.com" && self.password == "1234" {
                self.loginSuccess = true
            } else {
                self.errorMessage = "로그인 정보가 올바르지 않습니다."
            }
        }
    }
}
