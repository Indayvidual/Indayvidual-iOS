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
            VStack {
                Topbar(customAction: {
                    path.append(Route1.editCategory)
                })
                Spacer().frame(height: 18)
                CustomCalendarView(
                    calendarViewModel: calendarViewModel,
                    onDateSelected: { selectedDate in
                        // 날짜 선택 시 TodoViewModel의 selectedDate 업데이트
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        viewModel.selectedDate = formatter.string(from: selectedDate)
                    }
                )
                Spacer().frame(height: 20)
                
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
                    ScrollView {
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
                            
                    }.scrollBounceBehavior(.basedOnSize)
                }
                
                Spacer()
            }
            .background(.gray50)
            .navigationDestination(for: Route1.self) { route in
                switch route {
                case .selectCategory:
                    TodoCategorySelectView(
                        isEditMode: false,
                        onCategoryAdded: { name, color in
                            viewModel.addCategory(name: name, color: color)
                            path.removeLast()
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
}


#Preview {
    TodoListView(viewModel: TodoViewModel())
}
