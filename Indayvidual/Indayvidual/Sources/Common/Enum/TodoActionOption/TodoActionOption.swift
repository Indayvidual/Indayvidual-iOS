import Foundation

enum TodoActionOption: CaseIterable {
    case changeDate
    case doToday
    case doTomorrow
    case doAnotherDay
    case doTodoayAgain
    case delete
    
    var title: String {
        switch self {
        case .changeDate:
            return "날짜 바꾸기"
        case .doToday:
            return "오늘 하기"
        case .doTomorrow:
            return "내일 하기"
        case .doAnotherDay:
            return "다른 날 또 하기"
        case .doTodoayAgain :
            return "오늘 또 하기"
        case .delete:
            return "삭제하기"
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
        case .doTodoayAgain:
            return "doingarrow"
        case .delete:
            return ""
        }
    }
    
    // 특정 task와 현재 날짜에 따라 사용 가능한 옵션들 반환
    static func availableOptions(for task: TodoTask, currentDate: Date) -> [TodoActionOption] {
        let calendar = Calendar.current
        let taskDate = task.taskDate
        let today = calendar.startOfDay(for: currentDate)
        let taskDay = calendar.startOfDay(for: taskDate)
        
        var options: [TodoActionOption] = []
        
        if task.isCompleted {
            // 완료된 task의 경우
            if taskDay < today {
                // 과거 완료된 task
                options = [.changeDate, .doToday, .doTodoayAgain, .doAnotherDay]
            } else if taskDay == today {
                // 오늘 완료된 task
                options = [.changeDate, .doTomorrow, .doTodoayAgain, .doAnotherDay]
            } else {
                // 미래 완료된 task (일반적이지 않은 케이스)
                options = [.changeDate]
            }
        } else {
            // 미완료된 task의 경우
            if taskDay < today {
                // 과거 미완료된 task
                options = [.changeDate, .doToday, .doTomorrow, .doAnotherDay]
            } else if taskDay == today {
                // 오늘 미완료된 task
                options = [.changeDate, .doTomorrow]
            } else {
                // 미래 미완료된 task
                options = [.changeDate, .doToday, .doTodoayAgain, .doAnotherDay]
            }
        }
        return options
    }
}
