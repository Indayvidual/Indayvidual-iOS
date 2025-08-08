//
//  AlertService.swift
//  Indayvidual
//
//  Created by 장주리 on 8/8/25.
//

import SwiftUI

/// Alert 버튼의 종류를 정의하는 열거형
enum AlertButton {
    case primary(title: String, action: (() -> Void)? = nil)
    case secondary(title: String, action: (() -> Void)? = nil)
    
    var title: String {
        switch self {
        case .primary(let title, _), .secondary(let title, _):
            return title
        }
    }
    
    var action: (() -> Void)? {
        switch self {
        case .primary(_, let action), .secondary(_, let action):
            return action
        }
    }
}

/// Alert 정보를 담는 구조체 (Identifiable 프로토콜 준수)
struct AlertInfo: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?
}

/// 앱 전체의 Alert 상태를 관리하는 중앙 서비스 클래스
class AlertService: ObservableObject {
    @Published var alertInfo: AlertInfo?

    /// 공용 Alert을 표시하는 메서드
    /// - Parameters:
    ///   - title: Alert의 제목
    ///   - message: Alert의 내용 (옵셔널)
    ///   - primaryButton: 주 버튼 (예: 확인, 재시도)
    ///   - secondaryButton: 보조 버튼 (예: 취소) (옵셔널)
    func showAlert(
        title: String = "알림",
        message: String? = nil,
        primaryButton: AlertButton,
        secondaryButton: AlertButton? = nil
    ) {
        // UI 업데이트는 메인 스레드에서 실행
        DispatchQueue.main.async {
            self.alertInfo = AlertInfo(
                title: title,
                message: message,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton
            )
        }
    }
}
