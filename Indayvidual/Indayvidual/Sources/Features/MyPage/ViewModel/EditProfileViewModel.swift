//
//  EditProfileViewModel.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/10/25.
//

import Foundation
import Moya

class EditProfileViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var email: String = ""
    @Published var imageUrl: String?
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isEditingPassword: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let provider = MoyaProvider<ProfileAPITarget>()

    // 닉네임 변경 API 호출
    func updateNickname(nickname: String) {
        guard !nickname.isEmpty else {
            self.errorMessage = "닉네임을 입력해주세요."
            return
        }

        isLoading = true
        provider.request(.updateNickname(nickname: nickname)) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let responseData = try JSONDecoder().decode(ResponseDTO.self, from: response.data)
                    if responseData.isSuccess {
                        self?.errorMessage = nil
                    } else {
                        self?.errorMessage = responseData.message
                    }
                } catch {
                    self?.errorMessage = "닉네임 업데이트 실패: \(error.localizedDescription)"
                }
            case .failure(let error):
                self?.errorMessage = "서버 오류: \(error.localizedDescription)"
            }
            self?.isLoading = false
        }
    }

    // 비밀번호 변경 API 호출
    func updatePassword() {
        guard password == confirmPassword else {
            self.errorMessage = "비밀번호가 일치하지 않습니다."
            return
        }

        guard password.count >= 8 else {
            self.errorMessage = "비밀번호는 8글자 이상이어야 합니다."
            return
        }

        isLoading = true
        provider.request(.updatePassword(password: password)) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let responseData = try JSONDecoder().decode(ResponseDTO.self, from: response.data)
                    if responseData.isSuccess {
                        self?.errorMessage = nil
                    } else {
                        self?.errorMessage = responseData.message
                    }
                } catch {
                    self?.errorMessage = "비밀번호 변경 실패: \(error.localizedDescription)"
                }
            case .failure(let error):
                self?.errorMessage = "서버 오류: \(error.localizedDescription)"
            }
            self?.isLoading = false
        }
    }

    // 프로필 이미지 변경 API 호출
    func updateProfileImage(imageData: Data) {
        isLoading = true
        provider.request(.updateProfileImage(imageData: imageData)) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let responseData = try JSONDecoder().decode(ResponseDTO.self, from: response.data)
                    if responseData.isSuccess {
                        self?.imageUrl = responseData.data  // 이미지 URL을 서버 응답에서 받아옴
                        self?.errorMessage = nil
                    } else {
                        self?.errorMessage = responseData.message
                    }
                } catch {
                    self?.errorMessage = "이미지 업데이트 실패: \(error.localizedDescription)"
                }
            case .failure(let error):
                self?.errorMessage = "서버 오류: \(error.localizedDescription)"
            }
            self?.isLoading = false
        }
    }

    // 회원 탈퇴 API 호출
    func deleteAccount(hardDelete: Bool = false) {
        isLoading = true
        provider.request(.deleteAccount) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let responseData = try JSONDecoder().decode(ResponseDTO.self, from: response.data)
                    if responseData.isSuccess {
                        self?.errorMessage = nil
                    } else {
                        self?.errorMessage = responseData.message
                    }
                } catch {
                    self?.errorMessage = "회원 탈퇴 실패: \(error.localizedDescription)"
                }
            case .failure(let error):
                self?.errorMessage = "서버 오류: \(error.localizedDescription)"
            }
            self?.isLoading = false
        }
    }
}
