import SwiftUI

enum TodoActionOption: CaseIterable {
    case changeDate
    case doToday
    case doTomorrow
    case doAnotherDay
    
    var title: String {
        switch self {
        case .changeDate:
            return "날짜 바꾸기"
        case .doToday:
            return "오늘 하기"
        case .doTomorrow:
            return "오늘 또 하기"
        case .doAnotherDay:
            return "다른 날 또 하기"
        }
    }
    
    var iconName: String {
        switch self {
        case .changeDate:
            return "redo"
        case .doToday:
            return "doingarrow"
        case .doTomorrow:
            return "doingarrow"
        case .doAnotherDay:
            return "redo"
        }
    }
    
    var action: () -> Void {
        return {
            switch self {
            case .changeDate:
                print("날짜 바꾸기 선택됨")
            case .doToday:
                print("오늘 하기 선택됨")
            case .doTomorrow:
                print("오늘 또 하기 선택됨")
            case .doAnotherDay:
                print("다른 날 또 하기 선택됨")
            }
        }
    }
}

