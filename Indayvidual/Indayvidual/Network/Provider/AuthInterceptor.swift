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

    // refresh는 인터셉터 없는 세션으로 (순환 방지)
    private lazy var refreshProvider: MoyaProvider<AuthAPITarget> = {
        let session = Session(configuration: .default) // no interceptor
        return MoyaProvider<AuthAPITarget>(session: session)
    }()

    private var isRefreshing = false
    private var waiting: [(RetryResult) -> Void] = []
    private let lock = NSLock()

    init(userSession: UserSession) { self.userSession = userSession }

    // MARK: - adapt: 인증 경로 바이패스 + 그 외에만 Authorization 주입
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var req = urlRequest
        let path = req.url?.path ?? ""

        //  인증 우회 경로 (여기에선 Authorization 무조건 제거)
        let bypass: Set<String> = [
            "/api/auth/login",
            "/api/auth/refresh"
        ]

        if bypass.contains(path) {
            if req.value(forHTTPHeaderField: "Authorization") != nil {
                req.setValue(nil, forHTTPHeaderField: "Authorization")
            }
            return completion(.success(req))
        }

        // 일반 경로는 주입
        if !userSession.accessToken.isEmpty {
            req.setValue("Bearer \(userSession.accessToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(req))
    }

    // MARK: - retry: 401/403/419에서만 refresh → 재시도
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {

        let path = request.request?.url?.path ?? "nil"
        let status = request.response?.statusCode ?? -1
        print("🧩 [AuthInterceptor][retry] path=\(path) status=\(status) autoLogin=\(userSession.autoLogin)")

        // refresh 자신은 재시도 대상 제외
        if path == "/api/auth/refresh" {
            completion(.doNotRetry); return
        }

        // 인증 실패 코드만 재시도
        guard status == 401 || status == 403 || status == 419 else {
            completion(.doNotRetry); return
        }

        // 자동로그인 off 또는 RT 없음 → 종료
        guard userSession.autoLogin, !userSession.refreshToken.isEmpty else {
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
            guard let self else { return }
            var queuedResult: RetryResult = .doNotRetry

            switch result {
            case .success(let res):
                if (200..<300).contains(res.statusCode),
                   let dto = try? JSONDecoder().decode(RefreshResponseDTO.self, from: res.data),
                   dto.isSuccess, let data = dto.data {

                    DispatchQueue.main.async {
                        self.userSession.accessToken = data.accessToken
                        self.userSession.refreshToken = data.refreshToken
                    }
                    queuedResult = .retry
                } else {
                    DispatchQueue.main.async { self.userSession.clear() }
                }

            case .failure:
                DispatchQueue.main.async { self.userSession.clear() }
            }

            // 대기열 처리
            self.lock.lock()
            let queued = self.waiting
            self.waiting.removeAll()
            self.isRefreshing = false
            self.lock.unlock()

            queued.forEach { $0(queuedResult) }
        }
    }
}
