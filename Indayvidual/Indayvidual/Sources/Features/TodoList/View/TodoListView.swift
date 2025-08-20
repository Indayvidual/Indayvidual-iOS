import SwiftUI

enum Route1: Hashable {
    case selectCategory
    case editCategory
}

struct TodoListView: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var calendarViewModel: CustomCalendarViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var path = NavigationPath()
    @State private var hasLoadedInitialData = false
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        CalendarWithScheduleListView(
                            calendarViewModel: calendarViewModel,
                            homeViewModel: homeViewModel,
                            onDateSelected: { selectedDate in
                                homeViewModel.fetchSchedules(for: selectedDate)
                                
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                let dateString = formatter.string(from: selectedDate)
                                viewModel.selectedDate = dateString
                                
                                viewModel.loadTasks(for: dateString) { success in
                                    if !success {
                                        print("날짜 \(dateString)의 할 일 로드에 실패했습니다.")
                                    }
                                }
                            }
                        )
                        .padding(.vertical, 18)
                        .padding(.horizontal, 28)
                        
                        // task
                        if viewModel.categories.isEmpty {
                            Spacer().frame(height: 40)
                            EmptyTodoView()
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(viewModel.categories.enumerated()), id: \.element.categoryId) { index, category in
                                    CategoryRowView(
                                        category: category,
                                        viewModel: viewModel,
                                        date: viewModel.selectedDate
                                    )
                                    if index < viewModel.categories.count - 1 {
                                        Divider()
                                            .background(.gray200)
                                            .padding(.vertical, 16)
                                    }
                                }
                            }
                            .padding(.horizontal, 27)
                        }
                        
                        Spacer()
                    }.toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Image(.indayvidual)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                path.append(Route1.editCategory)
                            } label: {
                                Image("gear")
                            }
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .refreshable {
                    await refreshAllData()
                }
                .scrollContentBackground(.hidden)
            }
            .onAppear {
                if !hasLoadedInitialData {
                    refreshData()
                    hasLoadedInitialData = true
                }
            }
            .background(.gray50)
            .navigationDestination(for: Route1.self) { route in
                switch route {
                case .selectCategory:
                    TodoCategorySelectView(
                        todoViewModel: viewModel,
                        isEditMode: false,
                        onCategoryAdded: { name, color in }
                    )
                case .editCategory:
                    TodoCategoryEditView(viewModel: viewModel)
                }
            }
        }
        .floatingBtn {
            path.append(Route1.selectCategory)
        }
    }
    
    private func refreshData() {
        viewModel.fetchCategories()
    }
    
    @MainActor
    private func refreshAllData() async {
        viewModel.fetchCategories()
    }
}

#Preview {
    let alertService = AlertService()
    let homeViewModel = HomeViewModel()
//    let schedule1 = ScheduleItem(id: 1, startTime: Date(), endTime: Date().addingTimeInterval(3600), title: "회의", color: .blue, isAllDay: false)
//    let schedule2 = ScheduleItem(id: 2, startTime: Date().addingTimeInterval(7200), endTime: Date().addingTimeInterval(10800), title: "점심 약속", color: .orange, isAllDay: false)
//    let schedule3 = ScheduleItem(id: 3, startTime: nil, endTime: nil, title: "휴가", color: .green, isAllDay: true)
//    homeViewModel.filteredSchedules = [schedule1, schedule2, schedule3]
    
    let todoViewModel = TodoViewModel()
    todoViewModel.setup(with: alertService)
    
    return TodoListView(
        viewModel: todoViewModel,
        calendarViewModel: CustomCalendarViewModel(),
        homeViewModel: homeViewModel
    )
    .environmentObject(alertService)
}
