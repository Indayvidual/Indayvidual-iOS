import SwiftUI
// MARK: - CategoryEditCell
struct CategoryEditCell: View {
    let category: Category
    let isPendingDelete: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(height: 48)

                HStack(spacing: 12) {
                    HStack(spacing: 7) {
                        Image("categoryIcon")
                            .resizable()
                            .frame(width: 17, height: 17)
                        Text(category.name)
                            .font(.pretendSemiBold15)
                            .foregroundColor(.gray900)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .strikethrough(isPendingDelete, color: .red)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(category.color)
                    )

                    Spacer()

                    Menu {
                        Button("수정하기", action: onEdit)
                        Button("삭제하기", role: .destructive, action: onDelete)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .foregroundColor(.gray)
                            .frame(width: 32, height: 32)
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.trailing, 8)
                }
                .padding(.leading, 14)
                .padding(.trailing, 6)
            }
        }
        .padding(.horizontal, 20)
    }
}
// MARK: - TodoCategoryEditView
struct TodoCategoryEditView: View {
    @ObservedObject var viewModel: TodoViewModel
    @Environment(\.dismiss) var dismiss

    @State private var categoriesToDelete = Set<Int?>()
    @State private var editTarget: Category? = nil

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.categories, id: \.categoryId) { category in
                        CategoryEditCell(
                            category: category,
                            isPendingDelete: categoriesToDelete.contains(category.categoryId),
                            onEdit: {
                                editTarget = category
                                print("수정 대상 editing:", category)
                            },
                            onDelete: {
                                categoriesToDelete.insert(category.categoryId)
                            }
                        )
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color.gray50)
        }
        .background(Color.gray50.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image("back")
                }
            }
            ToolbarItem(placement: .principal) {
                Text("카테고리 수정")
                    .font(.pretendSemiBold18)
                    .foregroundStyle(.gray900)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    handleDeleteCompletion()
                }
                .font(.pretendSemiBold16)
                .foregroundColor(.gray900)
            }
        }
        .sheet(item: $editTarget) { editing in
            NavigationView {
                TodoCategorySelectView(
                    todoViewModel: viewModel,
                    initialName: editing.name,
                    initialColor: editing.color,
                    isEditMode: true,
                    categoryToUpdate: editing,
                    onCategoryAdded: { newName, newColor in
                        viewModel.updateCategory(editing, newName: newName, newColor: newColor)
                        editTarget = nil
                    }
                )
            }
        }
    }
    
    private func handleDeleteCompletion() {
        guard !categoriesToDelete.isEmpty else {
            dismiss()
            return
        }
        
        let validCategoriesToDelete = categoriesToDelete.compactMap { deleteId -> Category? in
            guard let deleteId = deleteId else { return nil }
            return viewModel.categories.first { $0.categoryId == deleteId }
        }
        
        print("🗑️ 삭제 대상 카테고리: \(validCategoriesToDelete.map { $0.name })")
        
        let group = DispatchGroup()
        var hasError = false
        
        for category in validCategoriesToDelete {
            group.enter()
            
            viewModel.deleteCategory(category) { success in
                if !success {
                    hasError = true
                    print("🔴 카테고리 \(category.name) 삭제 실패")
                } else {
                    print("🟢 카테고리 \(category.name) 삭제 성공")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if hasError {
                print("🔴 일부 카테고리 삭제 중 오류 발생")
            } else {
                print("🟢 모든 카테고리 삭제 완료")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dismiss()
            }
        }
    }
}

#Preview {
    let alertService = AlertService()
    let todoViewModel = TodoViewModel()
    todoViewModel.setup(with: alertService)
    
    return NavigationStack {
        TodoCategoryEditView(viewModel: todoViewModel)
            .environmentObject(alertService)
    }
}
