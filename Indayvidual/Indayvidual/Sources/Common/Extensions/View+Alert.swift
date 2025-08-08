//
//  RootAlertModifier.swift
//  Indayvidual
//
//  Created by 장주리 on 8/6/25.
//

import SwiftUI

/// AlertService를 감시하여 Alert을 실제로 표시하는 ViewModifier
struct RootAlertModifier: ViewModifier {
    @EnvironmentObject var alertService: AlertService

    func body(content: Content) -> some View {
        content
            .alert(item: $alertService.alertInfo) { info in
                // AlertInfo에 secondaryButton이 있으면 버튼 두 개, 없으면 한 개짜리 Alert 생성
                if let secondaryButton = info.secondaryButton {
                    Alert(
                        title: Text(info.title),
                        message: info.message != nil ? Text(info.message!) : nil,
                        primaryButton: .default(Text(secondaryButton.title), action: secondaryButton.action),
                        secondaryButton: .default(Text(info.primaryButton.title), action: info.primaryButton.action)
                    )
                } else {
                    Alert(
                        title: Text(info.title),
                        message: info.message != nil ? Text(info.message!) : nil,
                        dismissButton: .default(Text(info.primaryButton.title), action: info.primaryButton.action)
                    )
                }
            }
    }
}

// MARK: - 사용 방법
/// **1. 기본 Alert (확인 버튼 하나):**
/// ```swift
/// @EnvironmentObject var alertService: AlertService
///
/// Button("알림 표시") {
///     alertService.showAlert(
///         title: "알림",
///         message: "작업이 성공적으로 완료되었습니다.",
///         primaryButton: .default(Text("확인")) {
///             print("확인 버튼 클릭됨")
///         }
///     )
/// }
/// ```
///
/// **2. 두 개의 버튼을 가진 Alert (확인 및 취소):**
/// ```swift
/// @EnvironmentObject var alertService: AlertService
///
/// Button("확인/취소 알림") {
///     alertService.showAlert(
///         title: "경고",
///         message: "정말 삭제하시겠습니까?",
///         primaryButton: .default(Text("삭제")) {
///             print("삭제 버튼 클릭됨")
///         },
///         secondaryButton: .cancel(Text("취소")) {
///             print("취소 버튼 클릭됨")
///         }
///     )
/// }
/// ```
extension View {
    func rootAlert() -> some View {
        self.modifier(RootAlertModifier())
    }

}
