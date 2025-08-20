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
    private let refreshProvider = MoyaProvider<AuthAPITarget>()
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

        // 응답이 없으면(네트워크 에러 등) 여기서는 재시도하지 않음
        guard let statusCode = request.response?.statusCode else {
            completion(.doNotRetry)
            return
        }

        // 인증 실패로 취급할 상태코드들
        let isAuthFail = (statusCode == 401 || statusCode == 403 || statusCode == 419)

        // refresh 엔드포인트 자체거나, 인증실패가 아니면 재시도 안 함
        guard request.request?.url?.path != "/api/auth/refresh", isAuthFail else {
            completion(.doNotRetry)
            return
        }

        // 자동로그인 OFF면: refresh 시도 안 함 → 즉시 세션 클리어(루트가 로그인으로 분기)
        if userSession.autoLogin == false {
            DispatchQueue.main.async { self.userSession.clear() }
            completion(.doNotRetry)
            return
        }

        // refresh 토큰 없으면 재시도 불가
        guard !userSession.refreshToken.isEmpty else {
            DispatchQueue.main.async { self.userSession.clear() }
            completion(.doNotRetry)
            return
        }

        // 동시 refresh 제어
        lock.lock()
        if isRefreshing {
            waiting.append(completion)
            lock.unlock()
            return
        }
        isRefreshing = true
        waiting.append(completion)
        lock.unlock()

        refreshProvider.request(.refresh(refreshToken: userSession.refreshToken)) { [weak self] result in
            guard let self = self else { return }
            var queuedResult: RetryResult = .doNotRetry

            switch result {
            case .success(let res):
                // 필요시 (200..<300)으로 완화
                if res.statusCode == 200,
                   let dto = try? JSONDecoder().decode(AuthResponseDTO.self, from: res.data),
                   dto.isSuccess,
                   let data = dto.data {

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
                    queuedResult = .retry
                } else {
                    // 리프레시 실패 → 즉시 로그아웃 → 루트에서 로그인 화면으로
                    DispatchQueue.main.async { self.userSession.clear() }
                }

            case .failure:
                // 네트워크/서버 에러로 리프레시 자체 실패 → 즉시 로그아웃
                DispatchQueue.main.async { self.userSession.clear() }
            }

            // 응답 받은 뒤 대기열 처리 (타이밍 매우 중요)
            self.lock.lock()
            let queued = self.waiting
            self.waiting.removeAll()
            self.isRefreshing = false
            self.lock.unlock()

            queued.forEach { $0(queuedResult) }
        }
    }
}

enum Network {
    private static var appSession: UserSession?

    static func configure(userSession: UserSession) {
        self.appSession = userSession
    }

    static func provider<T: TargetType>() -> MoyaProvider<T> {
        guard let s = appSession else {
            return MoyaProvider<T>()
        }
        let interceptor = AuthInterceptor(userSession: s)
        let session = Session(interceptor: interceptor)
        return MoyaProvider<T>(session: session)
    }
}
