//
//  SignupViewModel.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/1/25.
//

import Foundation
import Moya

class SignupViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var code: String = ""
    @Published var password: String = ""
    @Published var nickname: String = ""
    @Published var phoneNumber: String = "010-0000-0000"

    @Published var isCodeValid: Bool = false
    @Published var signupSuccess: Bool = false
    @Published var errorMessage: String?

    let provider = MoyaProvider<SignupAPITarget>()

    func checkEmail(completion: @escaping (Bool) -> Void) {
        provider.request(.checkEmail(email: email)) { result in
            switch result {
            case .success(let response):
                print("✅ checkEmail 응답 코드: \(response.statusCode)")
                print("📦 Raw 응답:", String(data: response.data, encoding: .utf8) ?? "없음")

                do {
                    let decoded = try JSONDecoder().decode(CheckEmailResponse.self, from: response.data)

                    if decoded.isSuccess {
                        print("✅ 이메일 사용 가능")
                        completion(true)
                    } else {
                        print("⚠️ 중복 이메일 또는 기타 오류:", decoded.message)
                        self.errorMessage = decoded.message
                        completion(false)
                    }
                } catch {
                    print("❌ 디코딩 실패:", error)
                    self.errorMessage = "응답 파싱 오류"
                    completion(false)
                }

            case .failure(let error):
                print("❌ checkEmail 실패: \(error.localizedDescription)")
                self.errorMessage = "이메일 확인 중 오류 발생"
                completion(false)
            }
        }
    }

    func sendVerificationCode() {
        provider.request(.sendCode(email: email)) { result in
            switch result {
            case .success(let response):
                print("✅ 인증번호 전송 완료: \(response.statusCode)")
            case .failure(let error):
                print("❌ 인증번호 전송 실패: \(error.localizedDescription)")
                self.errorMessage = "인증번호 전송 실패"
            }
        }
    }

    func verifyCode(completion: @escaping (Bool) -> Void) {
        provider.request(.verifyCode(email: email, code: code)) { result in
            switch result {
            case .success(let response):
                self.isCodeValid = response.statusCode == 200
                print("✅ verifyCode 결과: \(self.isCodeValid)")
                completion(self.isCodeValid)
            case .failure(let error):
                print("❌ 인증 실패: \(error.localizedDescription)")
                self.isCodeValid = false
                self.errorMessage = "인증번호가 올바르지 않거나 만료되었습니다."
                completion(false)
            }
        }
    }

    func signup(completion: @escaping (Bool) -> Void) {
        let dto = SignupRequestDTO(
            email: email,
            password: password,
            nickname: nickname,
            phoneNumber: phoneNumber
        )

        // 요청 바디 디버깅용 출력
        if let encoded = try? JSONEncoder().encode(dto),
           let jsonString = String(data: encoded, encoding: .utf8) {
            print("📤 요청 바디: \(jsonString)")
        }

        provider.request(.signup(email: dto.email, password: dto.password, nickname: dto.nickname, phoneNumber: dto.phoneNumber)) { result in
            switch result {
            case .success(let response):
                print("📡 응답 코드: \(response.statusCode)")
                print("📦 Raw 응답: \(String(data: response.data, encoding: .utf8) ?? "응답 없음")")

                if response.statusCode == 200 {
                    print("🎉 회원가입 성공")
                    self.signupSuccess = true
                    completion(true)
                } else {
                    print("❌ 회원가입 실패 - 상태코드: \(response.statusCode)")
                    self.errorMessage = "회원가입 실패"
                    completion(false)
                }
            case .failure(let error):
                print("❌ 네트워크 에러: \(error.localizedDescription)")
                self.errorMessage = "서버와의 통신에 실패했습니다."
                completion(false)
            }
        }
    }

    
    var isValidEmail: Bool {
        guard !email.isEmpty else { return false }
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
