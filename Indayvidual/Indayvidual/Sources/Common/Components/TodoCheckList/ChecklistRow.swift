import SwiftUI

struct ChecklistRow: View {
    @Binding var isChecked: Bool
    @Binding var text: String
    let task: TodoTask
    @ObservedObject var actionViewModel: TodoActionViewModel
    @State private var showActionSheet = false
    @State private var currentActionOption: TodoActionOption? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                checkboxButton
                Spacer().frame(width: 12)
                textFieldSection
                Spacer()
                moreButton
                
            }
            .padding(.vertical, 3)
            underLine
        }
        .contentShape(Rectangle())
        .sheet(isPresented: $showActionSheet) {
            todoActionSheet
        }
        .sheet(isPresented: $actionViewModel.showDatePicker) {
            datePickerSheet
        }
    }
    
    private var checkboxButton: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isChecked ? Color.black : Color.grayWhite)
                    .frame(width: 17, height: 17)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isChecked ? Color.grayWhite : Color.gray400, lineWidth: 1)
                    )
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.grayWhite)
                } else {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.gray400)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textFieldSection: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text("할 일 입력")
                    .font(.pretendSemiBold12)
                    .foregroundColor(.gray400)
            }
            
            TextField("", text: $text)
                .font(.pretendSemiBold12)
                .foregroundColor(.black)
                .disabled(isChecked)
                .onChange(of: text) { oldValue, newValue in
                    if newValue.count > 50 {
                        text = String(newValue.prefix(50))
                    }
                }
        }
    }
    
    private var moreButton: some View {
        Button {
            showActionSheet = true
        } label: {
            Image("more-btn")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var underLine: some View {
        Rectangle()
            .foregroundColor(.black)
            .frame(height: 1)
            .padding(.leading, 27)
            .padding(.trailing, 20)
    }
    
    private var todoActionSheet: some View {
        CustomActionSheet(
            title: "일정 옵션",
            primaryButtonTitle: "삭제하기",
            secondaryButtonTitle: "수정하기",
            primaryAction: {
                actionViewModel.handleAction(.delete, for: task)
                showActionSheet = false
            },
            secondaryAction: {
                print("수정 선택됨")
                showActionSheet = false
            },
            primaryButtonColor: .systemError,
            primaryButtonTextColor: .grayWhite,
            secondaryButtonColor: .gray900,
            secondaryButtonTextColor: .grayWhite,
            secondaryButtonBorderColor: .gray100,
            secondaryButtonWidth: 175
        ) {
            TodoActionOptionsView(
                task: task,
                actionViewModel: actionViewModel,
                onActionSelected: { option in
                    currentActionOption = option
                    showActionSheet = false
                }
            )
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private var datePickerSheet: some View {
        CustomActionSheet(
            title: "일정 수정",
            titleIcon: "calendar",
            primaryButtonTitle: "일정 선택",
            secondaryButtonTitle: "취소",
            primaryAction: {
                if let currentOption = currentActionOption {
                    actionViewModel.handleDateSelection(for: task, option: currentOption)
                }
                currentActionOption = nil
            },
            secondaryAction: {
                actionViewModel.showDatePicker = false
                currentActionOption = nil
            },
            ) {
            CalendarWrapperView(
                initialSelectedDate: actionViewModel.selectedActionDate,
                onDateSelected: { selectedDate in
                    actionViewModel.selectedActionDate = selectedDate
                }
            )
        }
        .presentationDetents([.fraction(0.6)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Calendar Wrapper View
struct CalendarWrapperView: View {
    let initialSelectedDate: Date
    let onDateSelected: (Date) -> Void
    @StateObject private var calendarViewModel = CustomCalendarViewModel()
    
    var body: some View {
        CustomCalendarView(
            calendarViewModel: calendarViewModel,
            showToggleButton: false,
            showShadow: false,
            showNavigationButtons: true,
            showMarkers: false,
            initialMode: .month
        ) { date in
            onDateSelected(date)
        }
    }
}

// MARK: - Todo Action Options View
struct TodoActionOptionsView: View {
    let task: TodoTask
    let actionViewModel: TodoActionViewModel
    let onActionSelected: (TodoActionOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            ForEach(TodoActionOption.availableOptions(for: task, currentDate: Date()), id: \.self) { option in
                TodoActionOptionRow(option: option) {
                    onActionSelected(option)
                    actionViewModel.handleAction(option, for: task)
                }
            }
        }
    }
}

struct TodoActionOptionRow: View {
    let option: TodoActionOption
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(option.iconName)
                    .frame(width: 20, height: 20)
                Text(option.title)
                    .font(.pretendSemiBold17)
                    .foregroundStyle(.black)
                Spacer()
            }
        }
    }
}

// MARK: - 사용 예시

#Preview {
    let dummyTodoManager = TodoViewModel()
    let dummyActionViewModel = TodoActionViewModel(todoManager: dummyTodoManager)
    let dummyTask = TodoTask(
        taskId: 1,
        categoryId: 1,
        title: "프리뷰용 할 일",
        isCompleted: false,
        order: 0,
        date: "2024-06-01"
    )
    
    return PreviewWrapper(
        task: dummyTask,
        actionViewModel: dummyActionViewModel
    )
}

private struct PreviewWrapper: View {
    let task: TodoTask
    @ObservedObject var actionViewModel: TodoActionViewModel
    
    @State private var todoText = "프리뷰용 할 일"
    @State private var isChecked = false
    
    var body: some View {
        ChecklistRow(
            isChecked: $isChecked,
            text: $todoText,
            task: task,
            actionViewModel: actionViewModel
        )
        .padding()
    }
}
