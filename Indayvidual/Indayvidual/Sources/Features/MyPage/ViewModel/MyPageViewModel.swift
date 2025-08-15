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
            imageUrl = (session.provider == .kakao) ? session.avatarURL : nil
        }
    }
    
    func refreshIfReauthValid(session: UserSession) {
        guard session.provider == .kakao || isReauthValid() else { return }
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
                let raw = String(data: response.data, encoding: .utf8) ?? "nil"
#if DEBUG
                print("📡 /profile status:", response.statusCode)
                print("📦 /profile raw:", raw)
#endif
                
                // 1) 상태코드 확인
                guard (200...299).contains(response.statusCode) else {
                    if response.statusCode == 401 {
                        self.errorState = .reauthRequired
                        self.loadErrorMessage = "로그인이 만료되었어요. 재인증이 필요합니다."
                    } else {
                        self.errorState = .other("서버 오류(\(response.statusCode))")
                        self.loadErrorMessage = "서버 오류(\(response.statusCode))\n\(raw)"
                    }
                    return
                }
                
                // 2) 본문 비었는지 확인
                guard !response.data.isEmpty else {
                    self.errorState = .other("서버 응답이 비어 있습니다.")
                    self.loadErrorMessage = "서버 응답이 비어 있습니다."
                    return
                }
                
                // 3) 안전 디코드 (서버가 문자열만 보낼 수도 있음)
                do {
                    let dto = try JSONDecoder().decode(ProfileResponseDTO.self, from: response.data)
                    
                    if case let .message(msg)? = dto.data, msg.contains("재인증") {
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
                    self.loadErrorMessage = "디코딩 실패(\(response.statusCode)): \(error.localizedDescription)\nraw: \(raw)"
                }
                
            case .failure(let error):
                self.errorState = .other("네트워크 오류")
                self.loadErrorMessage = "네트워크 오류: \(error.localizedDescription)"
            }
        }
    }
}
