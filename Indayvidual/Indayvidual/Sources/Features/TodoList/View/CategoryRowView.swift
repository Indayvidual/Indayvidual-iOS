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
                List {
                    ForEach(viewModel.tasks(for: date, categoryId: category.categoryId ?? 0)) { task in
                        ChecklistRowWrapper(task: task, viewModel: viewModel)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 0)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .onMove { indices, newOffset in
                        viewModel.moveTask(from: indices, to: newOffset, date: date)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: CGFloat(viewModel.tasks(for: date, categoryId: category.categoryId ?? 0).count * 50))
                .transition(.opacity)
                .clipped()
                .refreshable {
                    await viewModel.loadTasksAsync(for: date, categoryId: category.categoryId ?? 0)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadTasksAsync(for: date, categoryId: category.categoryId ?? 0)
            }
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
    CategoryRowView(
        category: Category(categoryId: 1, name: "샘플 카테고리", color: .yellow01),
        viewModel: TodoViewModel(),
        date: "2024-06-01"
    )
}
