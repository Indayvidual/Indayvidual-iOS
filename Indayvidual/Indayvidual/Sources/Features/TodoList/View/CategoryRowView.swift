import SwiftUI

struct CategoryRowView: View {
    let category: Category
    @ObservedObject var viewModel: TodoViewModel
    let date: String // "yyyy-MM-dd" 형태
    
    @State private var isExpanded: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.grayWhite)
                    .frame(height: 39)
                HStack {
                    NameField(
                        category: category,
                        plusButtonAction: addChecklistItemIfAllowed
                    )
                    .padding(.leading, 10)
                    Spacer()
                    Button{
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    } label : {
                        Image("toggledown")
                            .rotationEffect(.degrees(isExpanded ? 0 : -180))
                            .animation(.easeInOut(duration: 0.3), value: isExpanded)
                    }.padding(.trailing)
                }
                
            }
            
            // MARK: - Task List
            if isExpanded {
                @State var categoryTasks = viewModel.tasks(for: date, categoryId: category.categoryId ?? 0)
                
                List {
                    ForEach(categoryTasks) { task in
                        ChecklistRowWrapper(task: task, viewModel: viewModel)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 0)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .onMove { indices, newOffset in
                        // moveCategoryTasks 메서드 호출
                        moveCategoryTasks(from: indices, to: newOffset)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: CGFloat(categoryTasks.count * 50))
                .transition(.opacity)
                .clipped()
                .refreshable {
                    await viewModel.loadTasksAsync(for: date, categoryId: category.categoryId ?? 0)
                }
                .onChange(of: viewModel.tasks(for: date, categoryId: category.categoryId ?? 0)) {
                        oldTasks, newTasks in
                        categoryTasks = newTasks
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadTasksAsync(for: date, categoryId: category.categoryId ?? 0)
            }
        }
    }
    
    private func moveCategoryTasks(from source: IndexSet, to destination: Int) {
        guard let categoryId = category.categoryId else { return }
        
        // 현재 날짜 + 카테고리 task 가져오기
        var currentCategoryTasks = viewModel.tasks(for: date, categoryId: categoryId)
        
        // 순서 변경
        currentCategoryTasks.move(fromOffsets: source, toOffset: destination)
        
        // ✨ [수정] 순서 변경 후, 각 task의 order 값을 새로운 인덱스에 맞게 재할당
        currentCategoryTasks = currentCategoryTasks.enumerated().map { index, task -> TodoTask in
            var updatedTask = task
            updatedTask.order = index
            return updatedTask
        }
        
        // ViewModel에 반영
        var allTasksForDate = viewModel.tasks[date] ?? []
        allTasksForDate.removeAll { $0.categoryId == categoryId }
        allTasksForDate.append(contentsOf: currentCategoryTasks)
        allTasksForDate.sort {
            if $0.categoryId == $1.categoryId {
                return $0.order < $1.order
            }
            return $0.categoryId < $1.categoryId
        }
        viewModel.tasks[date] = allTasksForDate
        
        // 서버에 전송
        let taskOrderInfos = currentCategoryTasks.compactMap { task -> TaskOrderInfo? in
            guard let taskId = task.taskId else { return nil }
            return TaskOrderInfo(taskId: taskId, categoryId: categoryId, order: task.order)
        }
        
        viewModel.updateTaskOrderForCategory(date: date, taskOrderInfos: taskOrderInfos)
    
        // 디버깅용
        print("📌 [DEBUG] \(date) / 카테고리 \(categoryId) 순서 변경 결과:")
        for t in viewModel.tasks(for: date, categoryId: categoryId).sorted(by: { $0.order < $1.order }) {
            print("   order:\(t.order)  title:\(t.title)")
        }
    }

    private func addChecklistItemIfAllowed() {
        viewModel.addTempTask(for: date, categoryId: category.categoryId ?? 0)
    }
}

// MARK: - ChecklistRow를 감싸는 Wrapper
struct ChecklistRowWrapper: View {
    let task: TodoTask
    @ObservedObject var viewModel: TodoViewModel
    @StateObject private var actionViewModel: TodoActionViewModel
    
    init(task: TodoTask, viewModel: TodoViewModel) {
        self.task = task
        self.viewModel = viewModel
        self._actionViewModel = StateObject(wrappedValue: TodoActionViewModel(todoManager: viewModel))
    }
    
    var body: some View {
        ChecklistRow(
            isChecked: Binding(
                get: { task.isCompleted },
                set: { _ in viewModel.toggleTask(task) }
            ),
            text: Binding(
                get: { task.title },
                set: { newValue in
                    viewModel.updateTaskTitle(task, newTitle: newValue)
                }
            ),
            task: task,
            actionViewModel: actionViewModel
        )
    }
}

// MARK: - Category Name Field
struct NameField: View {
    let category: Category
    @Environment(\.dismiss) var dismiss

    var plusButtonAction: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 5) {
            Image("categoryIcon")
                .resizable()
                .frame(width: 17, height: 10)

            Text(category.name)
                .font(.pretendSemiBold15)
                .foregroundStyle(.black)

            Button {
                plusButtonAction?()
            } label: {
                Image("plusBTN")
                    .resizable()
                    .frame(width: 15, height: 15)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 27)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(category.color)
                .frame(height: 27)
        )
    }
}

#Preview {
    let alertService = AlertService()
    let todoViewModel = TodoViewModel(alertService: alertService)
    
    return CategoryRowView(
        category: Category(categoryId: 1, name: "샘플 카테고리", color: .yellow01),
        viewModel: todoViewModel,
        date: "2024-06-01"
    )
    .environmentObject(alertService)
}
