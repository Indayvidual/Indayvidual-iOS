//
//  EditProfileViewModel.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/10/25.
//

import Foundation
import Moya
import UIKit

@MainActor
final class EditProfileViewModel: ObservableObject {
    private let provider = MoyaProvider<ProfileAPITarget>()

    // UI 상태
    @Published var isCheckingUsername = false
    @Published var isUsernameAvailable: Bool? = nil
    @Published var usernameCheckMessage: String?

    @Published var isUpdatingUsername = false
    @Published var isUpdatingPassword = false
    @Published var isUploadingImage = false

    @Published var toastMessage: String?
    @Published var deleteErrorMessage: String?

    // MARK: - 닉네임 중복 확인
    func checkNickname(_ username: String, currentNickname: String) {
        guard !username.isEmpty else {
            isUsernameAvailable = nil
            usernameCheckMessage = nil
            return
        }

        if username == currentNickname {
            isUsernameAvailable = true
            usernameCheckMessage = "현재 사용 중인 닉네임입니다."
            return
        }

        isCheckingUsername = true
        usernameCheckMessage = nil

        provider.request(.checkUsername(username: username)) { [weak self] result in
            guard let self = self else { return }
            self.isCheckingUsername = false
            switch result {
            case .success(let res):
                struct Resp: Decodable { let isSuccess: Bool; let data: Bool?; let message: String? }
                if let dto = try? JSONDecoder().decode(Resp.self, from: res.data),
                   dto.isSuccess, let ok = dto.data {
                    self.isUsernameAvailable = ok
                    self.usernameCheckMessage = ok ? "사용 가능한 닉네임입니다." : "이미 사용 중인 닉네임입니다."
                } else {
                    self.isUsernameAvailable = nil
                    self.usernameCheckMessage = "닉네임 확인에 실패했습니다."
                }
            case .failure:
                self.isUsernameAvailable = nil
                self.usernameCheckMessage = "네트워크 오류가 발생했습니다."
            }
        }
    }

    // MARK: - 닉네임 변경
    func updateUsername(_ username: String, onDone: (() -> Void)? = nil) {
        isUpdatingUsername = true
        provider.request(.updateUsername(username: username)) { [weak self] result in
            guard let self = self else { return }
            self.isUpdatingUsername = false
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    self.toastMessage = "닉네임이 변경되었습니다."
                    onDone?()
                } else if res.statusCode == 401 {
                    self.toastMessage = "재인증이 필요합니다."
                } else if res.statusCode == 404 {
                    self.toastMessage = "사용자를 찾을 수 없습니다."
                } else {
                    self.toastMessage = "닉네임 변경에 실패했습니다."
                }
            case .failure:
                self.toastMessage = "네트워크 오류로 닉네임 변경에 실패했습니다."
            }
        }
    }

    // MARK: - 비밀번호 변경
    func changePassword(current: String, new: String, completion: ((Bool) -> Void)? = nil) {
        provider.request(.updatePassword(currentPassword: current, newPassword: new)) { result in
            switch result {
            case .success(let response):
                do {
                    let dto = try JSONDecoder().decode(CommonResponseDTO.self, from: response.data)
                    if dto.isSuccess {
                        completion?(true)
                    } else {
                        completion?(false)
                    }
                } catch {
                    completion?(false)
                }
            case .failure:
                completion?(false)
            }
        }
    }


    // MARK: - 내 프로필 조회 (ProfileResponseDTO 사용)
    func fetchMyProfile(completion: @escaping (Profile?) -> Void) {
        provider.request(.getMyProfile) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do {
                        let dto = try JSONDecoder().decode(ProfileResponseDTO.self, from: res.data)
                        switch dto.data {
                        case .object(let profile):
                            completion(profile)
                        case .message(let msg):
                            self.toastMessage = msg
                            completion(nil)
                        case .none:
                            self.toastMessage = "프로필 응답이 비어 있습니다."
                            completion(nil)
                        }
                    } catch {
                        self.toastMessage = "프로필 파싱에 실패했습니다."
                        completion(nil)
                    }
                } else if res.statusCode == 401 {
                    self.toastMessage = "인증이 만료되었습니다. 다시 로그인해주세요."
                    completion(nil)
                } else if res.statusCode == 404 {
                    self.toastMessage = "사용자를 찾을 수 없습니다."
                    completion(nil)
                } else {
                    self.toastMessage = "프로필 조회에 실패했습니다. (\(res.statusCode))"
                    completion(nil)
                }
            case .failure:
                self.toastMessage = "네트워크 오류로 프로필을 불러오지 못했습니다."
                completion(nil)
            }
        }
    }

    // MARK: - 프로필 이미지 업로드 (≤5MB, JPG/PNG/WEBP)
    func uploadProfileImage(_ data: Data, filename: String, onDone: (() -> Void)? = nil) {
        guard data.count <= 5 * 1024 * 1024 else {
            toastMessage = "파일 용량(5MB) 초과입니다."
            return
        }
        let lower = filename.lowercased()
        let mime: String
        if lower.hasSuffix(".jpg") || lower.hasSuffix(".jpeg") {
            mime = "image/jpeg"
        } else if lower.hasSuffix(".png") {
            mime = "image/png"
        } else if lower.hasSuffix(".webp") {
            mime = "image/webp"
        } else {
            toastMessage = "JPG, PNG, WEBP만 업로드할 수 있습니다."
            return
        }

        isUploadingImage = true
        provider.request(.uploadProfileImage(data: data, fileName: filename, mimeType: mime)) { [weak self] result in
            guard let self = self else { return }
            self.isUploadingImage = false
            switch result {
            case .success(let res):
                switch res.statusCode {
                case 200:
                    self.toastMessage = "프로필 이미지가 변경되었습니다."
                    onDone?()
                case 400:
                    self.toastMessage = "잘못된 파일 혹은 허용되지 않은 형식입니다."
                case 401:
                    self.toastMessage = "재인증이 필요합니다."
                case 413:
                    self.toastMessage = "파일 용량(5MB) 초과입니다."
                case 502:
                    self.toastMessage = "업로드 실패가 발생했습니다."
                default:
                    self.toastMessage = "이미지 업로드에 실패했습니다."
                }
            case .failure:
                self.toastMessage = "네트워크 오류로 업로드에 실패했습니다."
            }
        }
    }

    // MARK: - 탈퇴 (placeholder)
    
    func deleteAccount(hard: Bool, completion: @escaping (Bool) -> Void) {
        provider.request(.deleteAccount(hard: hard)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let res):
                switch res.statusCode {
                case 200:
                    // 성공 응답 예: { isSuccess:true, code:"OK", message:"삭제 성공", data:"USER_DELETED" }
                    self.toastMessage = "회원 탈퇴가 완료되었습니다."
                    // 재인증 토큰은 1회성일 수 있으니 정리
                    UserDefaults.standard.removeObject(forKey: "reauthToken")
                    completion(true)
                case 401:
                    self.deleteErrorMessage = "재인증이 필요합니다."
                    completion(false)
                case 404:
                    self.deleteErrorMessage = "사용자를 찾을 수 없습니다."
                    completion(false)
                default:
                    self.deleteErrorMessage = "탈퇴에 실패했습니다. (\(res.statusCode))"
                    completion(false)
                }
            case .failure:
                self.deleteErrorMessage = "네트워크 오류로 탈퇴에 실패했습니다."
                completion(false)
            }
        }
    }
}
