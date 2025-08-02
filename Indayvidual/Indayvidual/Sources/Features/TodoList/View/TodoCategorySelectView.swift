import SwiftUI

struct TodoCategorySelectView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedColor: Color
    @State private var categoryName: String
    @State private var showColorPicker = false
    @StateObject private var colorViewModel = ColorViewModel()

    let onCategoryAdded: (String, Color) -> Void
    let isEditMode: Bool

    init(
        initialName: String = "",
        initialColor: Color = .purple05,
        isEditMode: Bool = false,
        onCategoryAdded: @escaping (String, Color) -> Void
    ) {
        self._categoryName = State(initialValue: initialName)
        self._selectedColor = State(initialValue: initialColor)
        self.onCategoryAdded = onCategoryAdded
        self.isEditMode = isEditMode
    }
    
    var body: some View {
        Group {
            if isEditMode {
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray300)
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                    
                    VStack(spacing: 20) {
                        Spacer().frame(height: 32)
                        
                        CustomPlaceholderTextField(text: $categoryName)
                        SelectColorField(selectedColor: $selectedColor, showColorPicker: $showColorPicker)
                        
                        Spacer().frame(height: 20)

                        Button {
                            if !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onCategoryAdded(categoryName, selectedColor)
                                dismiss()
                            }
                        } label: {
                            Text("완료")
                                .font(.pretendSemiBold16)
                                .foregroundStyle(.grayWhite)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray300 : Color.gray900)
                                )
                        }
                        .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray50)
                }
                .background(Color.gray50)
                .presentationDetents([.height(300), .medium])
                .presentationDragIndicator(.hidden)
            } else {
                VStack(spacing: 14) {
                    Spacer().frame(height: 8)
                    CustomPlaceholderTextField(text: $categoryName)
                    SelectColorField(selectedColor: $selectedColor, showColorPicker: $showColorPicker)
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
                            if !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onCategoryAdded(categoryName, selectedColor)
                                dismiss()
                            } else {
                                print("카테고리 이름을 입력해주세요")
                            }
                        }
                        .font(.pretendSemiBold18)
                        .foregroundStyle(.gray900)
                        .padding(.trailing, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showColorPicker) {
            CustomActionSheet(
                title: "색상 선택",
                titleIcon: "ic_color_lens_48px",
                primaryButtonTitle: "선택 완료",
                secondaryButtonTitle: "초기화",
                primaryAction: {
                    // 선택된 색상을 selectedColor에 적용
                    if let selectedColorModel = colorViewModel.colors.first(where: { $0.isSelected }) {
                        selectedColor = Color(selectedColorModel.name)
                    }
                    print("선택 완료 버튼 클릭")
                    showColorPicker = false
                },
                secondaryAction: {
                    colorViewModel.resetToDefault()
                    selectedColor = .purple05
                    print("초기화 버튼 클릭")
                    showColorPicker = false
                }
            ) {
                VStack(alignment: .leading) {
                    ColorGridView(viewModel: colorViewModel)
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
            
            if text.isEmpty {
                Text("카테고리 이름")
                    .foregroundColor(Color.gray400)
                    .font(.pretendSemiBold14)
                    .padding(.leading, 12)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: 335, height: 48)
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
        .frame(width: 335, height: 48)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray200)
                .fill(.grayWhite)
        )
    }
}

//extension ColorViewModel {
#Preview("TodoCategorySelectView - 등록") {
    NavigationView {
        TodoCategorySelectView(onCategoryAdded: { name, color in
            print("Preview - 카테고리 추가됨: \(name), 색상: \(color)")
        })
    }
}

#Preview("TodoCategorySelectView - 수정") {
    TodoCategorySelectView(
        initialName: "기존 카테고리",
        initialColor: .blue,
        isEditMode: true,
        onCategoryAdded: { name, color in
            print("Preview - 카테고리 수정됨: \(name), 색상: \(color)")
        }
    )
}
