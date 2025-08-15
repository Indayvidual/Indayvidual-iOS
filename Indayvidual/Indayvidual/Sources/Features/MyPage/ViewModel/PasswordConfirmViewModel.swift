//
//  PasswordConfirmViewModel.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/3/25.
//

import Foundation
import Moya

    @MainActor
final class PasswordConfirmViewModel: ObservableObject {
    @Published var errorMessage: String?
    
    private let profileProvider = MoyaProvider<ProfileAPITarget>()
    private let authProvider    = MoyaProvider<AuthAPITarget>()
    
    // 이메일 비번으로 재인증 → 프로필 조회
    func verifyPasswordAndFetchProfile(_ password: String) async -> Profile? {
        errorMessage = nil
        let ok = await requestReauthToken(password: password)
        guard ok else { return nil }
        return await fetchUserProfile()
    }
    
    // 카카오 재인증 → 프로필 조회
    func kakaoReauthAndFetchProfile(
        getKakaoAccessToken: @escaping () async throws -> String
    ) async -> Profile? {
        errorMessage = nil
        do {
            let kakaoAT = try await getKakaoAccessToken()
            
            let response: Response = try await withCheckedThrowingContinuation { cont in
                authProvider.request(.kakaoReauth(kakaoAccessToken: kakaoAT)) { result in
                    switch result {
                    case .success(let r): cont.resume(returning: r)
                    case .failure(let e): cont.resume(throwing: e)
                    }
                }
            }
            
            struct ReauthDTO: Decodable {
                struct DataPart: Decodable {
                    let reauthToken: String
                    let expiresInSeconds: Int
                }
                let isSuccess: Bool
                let message: String
                let data: DataPart?
            }
            
            let dto = try JSONDecoder().decode(ReauthDTO.self, from: response.data)
            guard dto.isSuccess, let d = dto.data else {
                errorMessage = dto.message
                return nil
            }
            
            saveReauth(token: d.reauthToken, expires: d.expiresInSeconds)
            return await fetchUserProfile()
            
        } catch {
            errorMessage = "카카오 재인증 실패: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Private
    
    private func requestReauthToken(password: String) async -> Bool {
        do {
            // 서버 스펙에 맞게 verifyPassword 호출(예: provider=email, password=입력값)
            let response: Response = try await withCheckedThrowingContinuation { cont in
                authProvider.request(.verifyPassword(provider: "email", password: password)) { result in
                    switch result {
                    case .success(let r): cont.resume(returning: r)
                    case .failure(let e): cont.resume(throwing: e)
                    }
                }
            }
            
            struct ReauthDTO: Decodable {
                struct DataPart: Decodable {
                    let reauthToken: String
                    let expiresInSeconds: Int
                }
                let isSuccess: Bool
                let message: String
                let data: DataPart?
            }
            
            let dto = try JSONDecoder().decode(ReauthDTO.self, from: response.data)
            guard dto.isSuccess, let d = dto.data else {
                errorMessage = dto.message
                return false
            }
            
            saveReauth(token: d.reauthToken, expires: d.expiresInSeconds)
            return true
            
        } catch {
            errorMessage = "재인증 실패: \(error.localizedDescription)"
            return false
        }
    }
    
    private func fetchUserProfile() async -> Profile? {
        do {
            let response: Response = try await withCheckedThrowingContinuation { cont in
                profileProvider.request(.getMyProfile) { result in
                    switch result {
                    case .success(let r): cont.resume(returning: r)
                    case .failure(let e): cont.resume(throwing: e)
                    }
                }
            }
            
            let dto = try JSONDecoder().decode(ProfileResponseDTO.self, from: response.data)
            
            guard dto.isSuccess else {
                errorMessage = dto.message
                return nil
            }
            
            if case let .object(p)? = dto.data {
                return p
            } else {
                errorMessage = "프로필 데이터가 없습니다."
                return nil
            }
            
        } catch {
            errorMessage = "프로필 조회 실패: \(error.localizedDescription)"
            return nil
        }
    }
    
    /// 10분 TTL reauthToken 저장
    private func saveReauth(token: String, expires: Int) {
        let exp = Date().addingTimeInterval(TimeInterval(expires)).timeIntervalSince1970
        UserDefaults.standard.set(token, forKey: "reauthToken")
        UserDefaults.standard.set(exp,   forKey: "reauthTokenExp")
    }
}


// 재인증 응답 DTO
struct ReauthResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let data: ReauthData
}
struct ReauthData: Decodable {
    let reauthToken: String
    let expiresInSeconds: Int
}
