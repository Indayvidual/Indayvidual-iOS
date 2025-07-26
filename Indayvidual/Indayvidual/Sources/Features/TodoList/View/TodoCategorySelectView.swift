import SwiftUI

struct TodoCategorySelectView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedColor: Color = .purple05
    @State private var categoryName: String = ""
    @State private var showColorPicker = false
    @StateObject private var colorViewModel = ColorViewModel()
    
    let onCategoryAdded: (String, Color) -> Void
    
    var body: some View {
        VStack(spacing: 14){
            Spacer().frame(height: 8)
            CustomPlaceholderTextField(text: $categoryName)
            SelectColorField(selectedColor: $selectedColor, showColorPicker: $showColorPicker)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 화면 전체 채우기!
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
                }.padding(.leading, 20)
            }

            ToolbarItem(placement: .principal) {
                Text("카테고리 등록")
                    .font(.pretendSemiBold18)
                    .foregroundStyle(.black)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("등록") {
                    // 카테고리 이름이 비어있지 않은 경우만 등록
                    if !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        // 콜백 함수 호출 >> 데이터 전달
                        onCategoryAdded(categoryName, selectedColor)
                        dismiss()
                    } else {
                        print("카테고리 이름을 입력해주세요")
                    }
                }
                .font(.pretendSemiBold18)
                .foregroundStyle(.black)
                .padding(.trailing, 20)
            }
        }
        .sheet(isPresented: $showColorPicker) {
            CustomActionSheet(
                title: "색상 선택",
                titleIcon: "bell.fill",
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

extension ColorViewModel {
    func resetToDefault() {
        for i in colors.indices {
            colors[i].isSelected = (colors[i].name == "purple05")
        }
    }
}

#Preview("TodoCategorySelectView") {
    TodoCategorySelectView(onCategoryAdded: { name, color in
        print("Preview - 카테고리 추가됨: \(name), 색상: \(color)")
    })
}
