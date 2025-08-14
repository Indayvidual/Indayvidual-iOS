import SwiftUI

enum Route1: Hashable {
    case selectCategory
    case editCategory
}

struct TodoListView: View {
    @ObservedObject var viewModel: TodoViewModel
    @StateObject private var calendarViewModel = CustomCalendarViewModel()
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                Topbar(customAction: {
                    path.append(Route1.editCategory)
                })
                ScrollView {
                    VStack {
                        CustomCalendarView(
                            calendarViewModel: calendarViewModel,
                            onDateSelected: { selectedDate in
                                // 날짜 선택 시 TodoViewModel의 selectedDate 업데이트
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
                        ).padding(.horizontal,28)
                        .padding(.vertical,26)
                        
                        if viewModel.categories.isEmpty {
                            VStack() {
                                Image("todo_checkbox")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                Spacer().frame(height: 16)
                                Text("등록된 할 일이 없습니다.")
                                    .font(.pretendMedium14)
                                    .foregroundStyle(.gray500)
                                Spacer().frame(height: 6)
                                Text("하단 + 버튼을 눌러서 카테고리를 생성해보세요.")
                                    .font(.pretendMedium12)
                                    .foregroundStyle(.gray500)
                            }
                            .padding(.horizontal,10)
                            .padding(.top,80)
                                
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
                                            .padding(.vertical,16)
                                    }
                                }
                            }.padding(.horizontal,27)
                        }
                        
                        Spacer()
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .refreshable {
                    await refreshAllData()
                }
                .scrollContentBackground(.hidden)
            }
            .onAppear {
                refreshData()
            }
            .background(.gray50)
            .navigationDestination(for: Route1.self) { route in
                switch route {
                case .selectCategory:
                    TodoCategorySelectView(
                        todoViewModel: viewModel,
                        isEditMode: false,
                        onCategoryAdded: { name, color in
                        }
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
    TodoListView(viewModel: TodoViewModel())
}
