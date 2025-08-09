//
//  MyPageViewModel.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/3/25.
//

import Foundation
import Moya

enum MyPageError: Equatable {
    case none
    case reauthRequired
    case other(String)
}

@MainActor
final class MyPageViewModel: ObservableObject {
    @Published var nickname = ""
    @Published var email = ""
    @Published var imageUrl: String?
    @Published var isLoading = false
    @Published var loadErrorMessage: String?
    @Published var errorState: MyPageError = .none

    private let provider = MoyaProvider<ProfileAPITarget>()
    init() {}

    /// 마이페이지 진입 시: reauth 유효하면만 프로필 로드 (서버 500/재인증 메시지 회피)
    func refreshIfReauthValid() {
        guard isReauthValid() else { return }
        fetchMyProfile()
    }

    private func isReauthValid() -> Bool {
        let token = UserDefaults.standard.string(forKey: "reauthToken") ?? ""
        let exp = UserDefaults.standard.double(forKey: "reauthTokenExp")
        let now = Date().timeIntervalSince1970
        return !token.isEmpty && exp > 0 && now < exp
    }

    func fetchMyProfile() {
        isLoading = true
        loadErrorMessage = nil
        errorState = .none

        provider.request(.getMyProfile) { [weak self] result in
            guard let self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                #if DEBUG
                print("📡 status:", response.statusCode)
                print("📦 body:", String(data: response.data, encoding: .utf8) ?? "nil")
                #endif

                guard !response.data.isEmpty else {
                    self.errorState = .other("서버 응답이 비어 있습니다.")
                    self.loadErrorMessage = "서버 응답이 비어 있습니다."
                    return
                }

                do {
                    let dto = try JSONDecoder().decode(ProfileResponseDTO.self, from: response.data)

                    // 서버가 data에 "재인증이 필요합니다." 같은 문자열을 줄 수 있음
                    if case let .message(msg)? = dto.data, msg.contains("재인증") {
                        // 자동 이동은 하지 않음 — 버튼으로 진입 시 PasswordConfirm에서 처리
                        self.errorState = .reauthRequired
                        return
                    }

                    guard dto.isSuccess else {
                        self.errorState = .other(dto.message)
                        self.loadErrorMessage = dto.message
                        return
                    }

                    if case let .object(p)? = dto.data {
                        self.email = p.email
                        self.nickname = (p.nickname?.isEmpty == false)
                            ? p.nickname!
                            : (p.email.split(separator: "@").first.map(String.init) ?? p.email)
                        self.imageUrl = p.imageUrl
                    } else {
                        self.errorState = .other("프로필 데이터가 없습니다.")
                        self.loadErrorMessage = "프로필 데이터가 없습니다."
                    }
                } catch {
                    self.errorState = .other("디코딩 실패")
                    self.loadErrorMessage = "디코딩 실패: \(error.localizedDescription)"
                }

            case .failure(let error):
                self.errorState = .other("네트워크 오류")
                self.loadErrorMessage = "네트워크 오류: \(error.localizedDescription)"
            }
        }
    }
}
