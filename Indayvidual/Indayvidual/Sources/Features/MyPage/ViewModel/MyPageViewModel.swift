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
    @Published var isDeleting = false
    @Published var deleteErrorMessage: String?
    
    private var provider: MoyaProvider<ProfileAPITarget> { Network.provider() }
    
    init() {}

    // 세션을 이용한 초기화
    func preload(from session: UserSession) {
        // 이메일/닉네임
        if nickname.isEmpty {
            if let cached = UserDefaults.standard.string(forKey: "nickname"), !cached.isEmpty {
                nickname = cached
            } else if !session.displayName.isEmpty {
                // 2순위: 세션에 들고 있는 표시 이름
                nickname = session.displayName
            } else {
                // 3순위: 아무것도 없을 때만 이메일 앞부분
                nickname = session.email.split(separator: "@").first.map(String.init) ?? ""
            }
        }
        
        if email.isEmpty {
            email = session.email
        }
        
        if imageUrl == nil {
            // 카카오 로그인 시 세션에서 프로필 이미지를 할당
            imageUrl = (session.provider == .kakao) ? session.avatarURL : nil
        }
    }
    
    // 재인증 여부 확인 및 프로필 정보 갱신
    func refreshIfReauthValid(session: UserSession) {
        guard session.provider == .kakao || isReauthValid() else { return }
        fetchMyProfile() // 카카오 프로필 정보 갱신
    }
    
    // 재인증 유효성 체크
    private func isReauthValid() -> Bool {
        let token = UserDefaults.standard.string(forKey: "reauthToken") ?? ""
        let exp = UserDefaults.standard.double(forKey: "reauthTokenExp")
        let now = Date().timeIntervalSince1970
        return !token.isEmpty && exp > 0 && now < exp
    }

    // 카카오 프로필 가져오기
    func fetchMyProfile() {
        isLoading = true
        loadErrorMessage = nil
        errorState = .none

        provider.request(.getMyProfile) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
    #if DEBUG
                print("📡 /profile status:", response.statusCode)
                if let raw = String(data: response.data, encoding: .utf8) {
                    print("📦 /profile raw:", raw)
                }
    #endif
                guard (200...299).contains(response.statusCode) else {
                    if response.statusCode == 401 {
                        self.errorState = .reauthRequired
                        self.loadErrorMessage = "로그인이 만료되었어요. 재인증이 필요합니다."
                    } else {
                        self.errorState = .other("서버 오류(\(response.statusCode))")
                        self.loadErrorMessage = "서버 오류(\(response.statusCode))"
                    }
                    return
                }

                guard !response.data.isEmpty else {
                    self.errorState = .other("서버 응답이 비어 있습니다.")
                    self.loadErrorMessage = "서버 응답이 비어 있습니다."
                    return
                }

                do {
                    let env = try JSONDecoder().decode(ProfileResponseDTO.self, from: response.data)
                    guard env.isSuccess else {
                        self.errorState = .other(env.message)
                        self.loadErrorMessage = env.message
                        return
                    }

                    guard case let .object(profile)? = env.data else {
                        if case let .message(msg)? = env.data {
                            self.errorState = .other(msg)
                            self.loadErrorMessage = msg
                        } else {
                            self.errorState = .other("프로필 데이터가 없습니다.")
                            self.loadErrorMessage = "프로필 데이터가 없습니다."
                        }
                        return
                    }

                    // 프로필 값 적용
                    self.email = profile.email ?? ""
                    self.nickname = profile.displayName   // displayName은 nickname → email 순
                    self.imageUrl = profile.imageUrl      // 프로필 이미지 URL을 업데이트

                    // 캐싱
                    UserDefaults.standard.set(self.nickname, forKey: "nickname")
                    UserDefaults.standard.set(self.imageUrl, forKey: "imageUrl")

                } catch {
                    self.errorState = .other("디코딩 실패")
                    self.loadErrorMessage = "디코딩 실패(\(response.statusCode)): \(error.localizedDescription)"
                }

            case .failure(let error):
                self.errorState = .other("네트워크 오류")
                self.loadErrorMessage = "네트워크 오류: \(error.localizedDescription)"
            }
        }
    }
}
