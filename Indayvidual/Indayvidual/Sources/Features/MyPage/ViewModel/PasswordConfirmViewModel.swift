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
    @Published var currentPassword: String = ""

    private let profileProvider = MoyaProvider<ProfileAPITarget>()

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
                profileProvider.request(.reauthKakao(kakaoAccessToken: kakaoAT)) { result in
                    switch result {
                    case .success(let r): cont.resume(returning: r)
                    case .failure(let e): cont.resume(throwing: e)
                    }
                }
            }

            // 관대한 래퍼
            struct ReauthEnvelope: Decodable {
                let isSuccess: Bool?
                let code: String?
                let message: String?
                let data: DataPart?
                struct DataPart: Decodable {
                    let reauthToken: String?
                    let expiresInSeconds: Int?
                }
            }

            // 디코드 시도
            let dto = try JSONDecoder().decode(ReauthEnvelope.self, from: response.data)
            guard let ok = dto.isSuccess, ok,
                  let token = dto.data?.reauthToken,
                  let ttl = dto.data?.expiresInSeconds
            else {
                errorMessage = dto.message ?? "재인증 실패(\(response.statusCode))"
                // 디버깅용 원문 남기기
                #if DEBUG
                print("reauth kakao raw:", String(data: response.data, encoding: .utf8) ?? "nil")
                #endif
                return nil
            }

            saveReauth(token: token, expires: ttl)
            return await fetchUserProfile()

        } catch {
            errorMessage = "카카오 재인증 실패: \(error.localizedDescription)"
            return nil
        }
    }

    // MARK: - Private

    private func requestReauthToken(password: String) async -> Bool {
        do {
            let response: Response = try await withCheckedThrowingContinuation { cont in
                profileProvider.request(.reauthPassword(currentPassword: password)) { result in
                    switch result {
                    case .success(let r): cont.resume(returning: r)
                    case .failure(let e): cont.resume(throwing: e)
                    }
                }
            }

            struct ReauthEnvelope: Decodable {
                let isSuccess: Bool?
                let code: String?
                let message: String?
                let data: DataPart?
                struct DataPart: Decodable {
                    let reauthToken: String?
                    let expiresInSeconds: Int?
                }
            }

            guard !response.data.isEmpty else {
                errorMessage = "서버 응답이 비어 있습니다. (\(response.statusCode))"
                return false
            }

            let dto = try JSONDecoder().decode(ReauthEnvelope.self, from: response.data)
            guard let ok = dto.isSuccess, ok,
                  let token = dto.data?.reauthToken,
                  let ttl = dto.data?.expiresInSeconds
            else {
                errorMessage = dto.message ?? "재인증 실패(\(response.statusCode))"
                #if DEBUG
                print("reauth pw raw:", String(data: response.data, encoding: .utf8) ?? "nil")
                #endif
                return false
            }

            saveReauth(token: token, expires: ttl)
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

            guard !response.data.isEmpty else {
                errorMessage = "프로필 응답이 비어 있습니다. (\(response.statusCode))"
                return nil
            }

            let env = try JSONDecoder().decode(ProfileResponseDTO.self, from: response.data)

            guard env.isSuccess else {
                errorMessage = env.message
                return nil
            }

            // ✅ enum 스위칭으로 Profile 꺼내기
            guard case let .object(p)? = env.data else {
                // 서버가 data에 문자열 메시지를 넣어 보낼 때 대비
                if case let .message(msg)? = env.data {
                    errorMessage = msg
                } else {
                    errorMessage = "프로필 데이터가 없습니다."
                }
                return nil
            }

            // p는 너가 정의한 Profile( email: String?, nickname: String?, imageUrl: String? )
            // 필요하면 표시용 닉네임은 p.displayName 사용 가능
            return p

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
