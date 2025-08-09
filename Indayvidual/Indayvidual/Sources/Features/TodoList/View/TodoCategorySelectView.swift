import SwiftUI

struct TodoCategorySelectView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedColor: Color
    @State private var categoryName: String
    @State private var showColorPicker = false
    @StateObject private var colorViewModel = ColorViewModel()
    @ObservedObject var todoViewModel: TodoViewModel
    private let categoryToUpdate: Category?
    
    let onCategoryAdded: (String, Color) -> Void
    let isEditMode: Bool
    
    init(
        todoViewModel: TodoViewModel,
        initialName: String = "",
        initialColor: Color = .purple05,
        isEditMode: Bool = false,
        categoryToUpdate: Category? = nil,
        onCategoryAdded: @escaping (String, Color) -> Void
    ) {
        self._categoryName = State(initialValue: initialName)
        self._selectedColor = State(initialValue: initialColor)
        self.todoViewModel = todoViewModel
        self.onCategoryAdded = onCategoryAdded
        self.categoryToUpdate = categoryToUpdate
        self.isEditMode = isEditMode
    }
    
    var body: some View {
        Group {
            if isEditMode {
                editModeView
            } else {
                normalModeView
            }
        }
        .sheet(isPresented: $showColorPicker) {
            colorPickerSheet
        }
        .onAppear {
            todoViewModel.fetchCategories() // 뷰 등장 시 카테고리 목록 조회
        }
    }

    // MARK: - Edit Mode View
    private var editModeView: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray300)
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            VStack(spacing: 20) {
                Spacer().frame(height: 32)
                CustomPlaceholderTextField(text: $categoryName)
                SelectColorField(selectedColor: $selectedColor, showColorPicker: $showColorPicker)
                statusView
                Spacer().frame(height: 20)

                Button {
                    handleCategorySubmission()
                } label: {
                    Text("완료")
                        .font(.pretendSemiBold16)
                        .foregroundStyle(.grayWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(buttonBackgroundColor)
                        )
                }
                .disabled(isButtonDisabled)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray50)
        }
        .background(Color.gray50)
        .presentationDetents([.height(300), .medium])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Normal Mode View
    private var normalModeView: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 8)
            CustomPlaceholderTextField(text: $categoryName)
            SelectColorField(selectedColor: $selectedColor, showColorPicker: $showColorPicker)
            statusView
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray50)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image("back")
                    }
                }.padding(.leading, 15)
            }
            ToolbarItem(placement: .principal) {
                Text("카테고리 등록")
                    .font(.pretendSemiBold18)
                    .foregroundStyle(.black)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("등록") {
                    handleCategorySubmission()
                }
                .font(.pretendSemiBold18)
                .foregroundStyle(buttonBackgroundColor)
                .disabled(isButtonDisabled)
                .padding(.trailing, 20)
            }
        }
    }

    // MARK: - Status View
    private var statusView: some View {
        VStack(spacing: 8) {
            if let errorMessage = todoViewModel.errorMessage {
                Text("Error - \(errorMessage)")
                    .font(.pretendMedium12)
                    .foregroundStyle(.systemError)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Color Picker Sheet
    private var colorPickerSheet: some View {
        CustomActionSheet(
            title: "색상 선택",
            titleIcon: "ic_color_lens_48px",
            primaryButtonTitle: "선택 완료",
            secondaryButtonTitle: "초기화",
            primaryAction: {
                if let selectedColorModel = colorViewModel.colors.first(where: { $0.isSelected }) {
                    selectedColor = Color(selectedColorModel.name)
                }
                
                showColorPicker = false
            },
            secondaryAction: {
                colorViewModel.resetToDefault()
                selectedColor = .purple05
                showColorPicker = false
            }
        ) {
            VStack(alignment: .leading) {
                ColorGridView(viewModel: colorViewModel)
            }
        }
    }

    // MARK: - 버튼 기능과 색상 변화
    private var isButtonDisabled: Bool { categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var buttonBackgroundColor: Color {
        isButtonDisabled ? Color.gray300 : Color.gray900
    }

    // MARK: - Methods
    private func handleCategorySubmission() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)

        if isEditMode {
            guard let targetCategory = categoryToUpdate else {
               return
           }
            todoViewModel.updateCategory(
                targetCategory, newName: trimmedName,
                newColor: selectedColor
            ) { success in
                if success {
                    DispatchQueue.main.async {
                        dismiss()
                        onCategoryAdded(trimmedName, selectedColor)
                    }
                } else {
                    todoViewModel.errorMessage = "카테고리 수정에 실패했습니다. 다시 시도해 주세요."
                }
            }
        } else {
            todoViewModel.addCategory(name: trimmedName, color: selectedColor) { success in
                if success {
                    DispatchQueue.main.async {
                        dismiss()
                        onCategoryAdded(trimmedName, selectedColor)
                    }
                } else {
                    todoViewModel.errorMessage = "카테고리 등록에 실패했습니다. 다시 시도해 주세요."
                }
            }
        }
    }
}

struct CustomPlaceholderTextField: View {
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray200)
                .fill(.grayWhite)
            
            TextField("", text: $text)
                .padding(.horizontal, 12)
                .font(.pretendSemiBold14)
                .background(Color.clear)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
            
            if text.isEmpty {
                Text("카테고리 이름")
                    .foregroundColor(Color.gray400)
                    .font(.pretendSemiBold14)
                    .padding(.leading, 12)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: 48)
        .padding(.horizontal,20)
    }
}

struct SelectColorField: View {
    @Binding var selectedColor: Color
    @Binding var showColorPicker: Bool

    var body: some View {
        Button {
            showColorPicker = true
        } label: {
            HStack {
                Text("색상 선택")
                    .font(.pretendMedium14)
                    .foregroundStyle(.black)
                    .padding(.leading, 12)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(selectedColor)
                        .frame(width: 25, height: 25)
                    
                    Image("downDrop")
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 16)
            }
        }
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray200)
                .fill(.grayWhite)
        )
        .padding(.horizontal,20)
    }
}

#Preview("TodoCategorySelectView - 등록") {
    NavigationView {
        TodoCategorySelectView(
            todoViewModel: TodoViewModel(),
            onCategoryAdded: { name, color in
                print("Preview - 카테고리 추가됨: \(name), 색상: \(color)")
            }
        )
    }
}

#Preview("TodoCategorySelectView - 수정") {
    TodoCategorySelectView(
        todoViewModel: TodoViewModel(),
        initialName: "기존 카테고리",
        initialColor: .blue,
        isEditMode: true,
        onCategoryAdded: { name, color in
            print("Preview - 카테고리 수정됨: \(name), 색상: \(color)")
        }
    )
}
