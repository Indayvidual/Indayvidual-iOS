//
//  NetworkKit.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/21/25.
//

import Moya
import Alamofire
import Foundation

enum NetworkKit {
    private static var _userSession: UserSession?
    private static var _interceptor: AuthInterceptor?
    private static var _session: Session?
    private static var _publicSession: Session?
    private static var _isConfigured = false

    #if DEBUG
    static let logger = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    #else
    static let logger = NetworkLoggerPlugin(configuration: .init(logOptions: []))
    #endif

    /// 앱 시작 후(뷰 트리에 userSession 설치된 뒤) 단 한 번 호출
    static func configure(userSession: UserSession) {
        guard !_isConfigured else { return } // ✅ 중복 방지

        _userSession = userSession
        _interceptor = AuthInterceptor(userSession: userSession)

        // 필요시 타임아웃·캐시 등 조정
        let config = URLSessionConfiguration.default
        _session = Session(configuration: config, interceptor: _interceptor)

        // 인증계열용(로그인/카카오/리프레시/로그아웃): 인터셉터 없는 세션
        _publicSession = Session(configuration: .default)

        _isConfigured = true
        print("✅ NetworkKit configured. interceptor=\(_interceptor != nil)")
    }

    /// 인터셉터가 붙은 공용 Provider — 일반 API는 전부 이걸 사용
    static func provider<T: TargetType>() -> MoyaProvider<T> {
        guard let session = _session else {
            assertionFailure("⚠️ NetworkKit not configured. Returning non-intercepted provider.")
            return MoyaProvider<T>(plugins: [logger])
        }
        return MoyaProvider<T>(session: session, plugins: [logger])
    }

    /// 인증계열용 Provider — 로그인/카카오/리프레시/로그아웃만 여기로
    static func publicAuthProvider() -> MoyaProvider<AuthAPITarget> {
        if let s = _publicSession {
            return MoyaProvider<AuthAPITarget>(session: s, plugins: [logger])
        } else {
            // configure 전에 호출되었을 때의 안전장치
            let s = Session(configuration: .default)
            return MoyaProvider<AuthAPITarget>(session: s, plugins: [logger])
        }
    }

    /// (선택) 완전 초기화 — 로그아웃 등에서 필요하면 사용
    static func reset() {
        _session = nil
        _publicSession = nil
        _interceptor = nil
        _userSession = nil
        _isConfigured = false
    }
}
