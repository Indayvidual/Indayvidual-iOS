//
//  TabCase.swift
//  Indayvidual
//
//  Created by 김도연 on 7/6/25.
//

import Foundation
import SwiftUI

enum TabCase: String, CaseIterable{
    case home = "홈"
    case todo = "투두"
    case timetable = "시간표"
    case custom = "커스텀"
    case settings = "설정"
    
    var icon: Image{
        switch self{
        case .home :
            return .init(.home)
        case .todo :
            return .init(.todo)
        case .timetable :
            return .init(systemName: "clock")
        case .custom :
            return .init(.custom)
        case .settings :
            return .init(.settings)
        }
    }
}
