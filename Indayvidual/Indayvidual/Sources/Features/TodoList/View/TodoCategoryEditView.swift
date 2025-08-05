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
            HStack {
                Button(action: { dismiss() }) {
                    Image("back")
                }
                .padding(.leading, 20)
                Spacer()
                Text("카테고리 수정")
                    .font(.pretendSemiBold18)
                    .foregroundStyle(.gray900)
                Spacer()
                Button("완료") {
                    for deleteId in categoriesToDelete {
                        if let deleteId,
                           let category = viewModel.categories.first(where: { $0.categoryId == deleteId }) {
                            viewModel.deleteCategory(category)
                        }
                    }
                    dismiss()
                }
                .font(.pretendSemiBold16)
                .foregroundColor(.gray900)
                .padding(.trailing, 20)
            }
            .frame(height: 48)
            .background(Color.gray50)

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
        .sheet(item: $editTarget) { editing in
            NavigationView {
                TodoCategorySelectView(
                    initialName: editing.name,
                    initialColor: editing.color,
                    isEditMode: true,
                    onCategoryAdded: { newName, newColor in
                        viewModel.updateCategory(editing, newName: newName, newColor: newColor)
                        editTarget = nil
                    }
                )
            }
        }
    }
}
#Preview {
    TodoCategoryEditView(viewModel: TodoViewModel())
}
