//
//  SignupViewModel.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/1/25.
//

import Foundation
import Moya

enum EmailCheckStatus {
    case available
    case duplicate
    case failed(String)
}

class SignupViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var code: String = ""
    @Published var password: String = ""
    @Published var nickname: String = ""
    @Published var phoneNumber: String = "010-0000-0000"

    @Published var isCodeValid: Bool = false
    @Published var signupSuccess: Bool = false
    @Published var errorMessage: String?
    
    @Published var emailCheckStatus: EmailCheckStatus? = nil

    let provider: MoyaProvider<SignupAPITarget> = NetworkKit.provider()

    func checkEmail(completion: @escaping (Bool) -> Void) {
        provider.request(.checkEmail(email: email)) { result in
            switch result {
            case .success(let response):
                do {
                    let dto = try JSONDecoder().decode(CheckEmailResponse.self, from: response.data)

                    // 상태코드 우선 판단(선택)
                    if response.statusCode == 400 {
                        DispatchQueue.main.async {
                            self.emailCheckStatus = .failed("올바른 이메일 형식이 아닙니다.")
                            self.errorMessage = "올바른 이메일 형식이 아닙니다."
                        }
                        completion(false)
                        return
                    }

                    // ✅ 핵심: data == true 가 “사용 가능”, false 가 “중복”
                    if dto.data == true {
                        DispatchQueue.main.async {
                            self.emailCheckStatus = .available
                            self.errorMessage = nil
                        }
                        completion(true)
                    } else if dto.data == false {
                        DispatchQueue.main.async {
                            self.emailCheckStatus = .duplicate
                            self.errorMessage = dto.message ?? "이미 가입된 이메일입니다."
                        }
                        completion(false)
                    } else {
                        // data 가 nil 이거나 응답 형식 이상
                        DispatchQueue.main.async {
                            self.emailCheckStatus = .failed("응답 파싱 오류")
                            self.errorMessage = "응답 파싱 오류"
                        }
                        completion(false)
                    }

                } catch {
                    DispatchQueue.main.async {
                        self.emailCheckStatus = .failed("응답 파싱 오류")
                        self.errorMessage = "응답 파싱 오류"
                    }
                    completion(false)
                }

            case .failure:
                DispatchQueue.main.async {
                    self.emailCheckStatus = .failed("이메일 확인 중 오류 발생")
                    self.errorMessage = "이메일 확인 중 오류 발생"
                }
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
