//
//  AuthInterceptor.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/19/25.
//

import Foundation
import Alamofire
import Moya

final class AuthInterceptor: RequestInterceptor {
    private let userSession: UserSession
    private let refreshProvider = MoyaProvider<AuthAPITarget>() // 인터셉터 미적용(재귀 방지)
    private var isRefreshing = false
    private var waiting: [(RetryResult) -> Void] = []
    private let lock = NSLock()
    
    init(userSession: UserSession) { self.userSession = userSession }
    
    // 매 요청에 액세스 토큰 부착 (refresh API 제외)
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var req = urlRequest
        if req.url?.path != "/api/auth/refresh",
           !userSession.accessToken.isEmpty {
            req.setValue("Bearer \(userSession.accessToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(req))
    }
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        
        // refresh 자체 실패거나 401이 아니면 재시도 안 함
        guard request.request?.url?.path != "/api/auth/refresh",
              request.response?.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        // refresh 토큰이 없으면 재시도 불가
        guard !userSession.refreshToken.isEmpty else {
            completion(.doNotRetry)
            return
        }
        
        lock.lock(); defer { lock.unlock() }
        
        // 이미 리프레시 중이면 대기열에 completion 추가
        if isRefreshing {
            waiting.append(completion)
            return
        }
        
        isRefreshing = true
        waiting.append(completion)
        
        // 기본값: 실패 시 재시도하지 않음
        var retryResultForQueued: RetryResult = .doNotRetry
        
        refreshProvider.request(.refresh(refreshToken: userSession.refreshToken)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let res):
                if res.statusCode == 200,
                   let dto = try? JSONDecoder().decode(AuthResponseDTO.self, from: res.data),
                   dto.isSuccess,
                   let data = dto.data {
                    
                    // AuthData -> TokenInfo 매핑
                    let token = TokenInfo(
                        accessToken: data.accessToken,
                        refreshToken: data.refreshToken,
                        userId: data.userId,
                        email: data.email,
                        nickname: data.username,
                        role: data.role
                    )
                    
                    DispatchQueue.main.async {
                        self.userSession.updateSession(token: token)
                    }
                    retryResultForQueued = .retry
                } else {
                    DispatchQueue.main.async { self.userSession.clear() }
                    retryResultForQueued = .doNotRetry
                }
                
            case .failure:
                DispatchQueue.main.async { self.userSession.clear() }
                retryResultForQueued = .doNotRetry
            }
        }
        
        // 대기 중이던 요청들 처리
        self.lock.lock()
        let queued = self.waiting
        self.waiting.removeAll()
        self.isRefreshing = false
        self.lock.unlock()
        
        queued.forEach { $0(retryResultForQueued) }
    }
}

// 공용 MoyaProvider 빌더(이 Provider는 AuthInterceptor가 붙음)
enum Network {
    static func provider<T: TargetType>(userSession: UserSession) -> MoyaProvider<T> {
        let interceptor = AuthInterceptor(userSession: userSession)
        let session = Session(interceptor: interceptor)
        return MoyaProvider<T>(session: session)
    }
}
