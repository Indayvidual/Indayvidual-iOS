//
//  AuthenticatedTarget.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/21/25.
//

import Moya
protocol AuthenticatedTarget: TargetType {}
extension AuthenticatedTarget {
    var validationType: ValidationType { .successCodes }
}

// 각 타겟에 채택
extension EventTarget: AuthenticatedTarget {}
extension CalendarTarget: AuthenticatedTarget {}
extension ProfileAPITarget: AuthenticatedTarget {}
extension TodoCategoryAPITarget: AuthenticatedTarget {}
extension TodoChecklistAPITarget: AuthenticatedTarget {}
extension MemoAPITarget: AuthenticatedTarget {}
extension HabitAPITarget: AuthenticatedTarget {}
extension TimetableTarget: AuthenticatedTarget {}
extension ReauthAPITarget: AuthenticatedTarget {}
