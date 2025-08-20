import SwiftUI

enum Route1: Hashable {
    case selectCategory
    case editCategory
}

// MARK: - Main View

struct TodoListView: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var calendarViewModel: CustomCalendarViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var path = NavigationPath()
    @State private var hasLoadedInitialData = false
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                TodoContentScrollView(
                    viewModel: viewModel,
                    calendarViewModel: calendarViewModel,
                    homeViewModel: homeViewModel
                )
            }
            .scrollBounceBehavior(.basedOnSize)
            .refreshable {
                await refreshAllData()
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
            .toolbar {
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
        .floatingBtn {
            path.append(Route1.selectCategory)
        }
    }
    
    // MARK: - Subviews

    private struct TodoContentScrollView: View {
        @ObservedObject var viewModel: TodoViewModel
        @ObservedObject var calendarViewModel: CustomCalendarViewModel
        @ObservedObject var homeViewModel: HomeViewModel
        
        var body: some View {
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
                    
                    TodoTaskListView(viewModel: viewModel)
                        .padding(.bottom, 80)
                }
                .scrollContentBackground(.hidden)
            }
        }
    }

    private struct TodoTaskListView: View {
        @ObservedObject var viewModel: TodoViewModel
        
        var body: some View {
            if viewModel.categories.isEmpty {
                Spacer()
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
        }
    }
    
    // MARK: - Helper Functions
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
    
    let todoViewModel = TodoViewModel()
    todoViewModel.setup(with: alertService)
    
    return TodoListView(
        viewModel: todoViewModel,
        calendarViewModel: CustomCalendarViewModel(),
        homeViewModel: homeViewModel
    )
    .environmentObject(alertService)
}
