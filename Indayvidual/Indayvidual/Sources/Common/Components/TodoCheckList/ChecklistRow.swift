import SwiftUI

struct ChecklistRow: View {
    @Binding var isChecked: Bool
    @Binding var text: String
    @State private var showActionSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                checkboxButton
                Spacer().frame(width: 12)
                textFieldSection
                Spacer()
                moreButton
                
            }
            .padding(.vertical, 3)
            underLine
        }
        .contentShape(Rectangle())
        .sheet(isPresented: $showActionSheet) {
            todoActionSheet
        }
    }
    
    private var checkboxButton: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isChecked ? Color.black : Color.grayWhite)
                    .frame(width: 17, height: 17)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isChecked ? Color.grayWhite : Color.gray400, lineWidth: 1)
                    )
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textFieldSection: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text("할 일 입력")
                    .font(.pretendSemiBold12)
                    .foregroundColor(.gray400)
            }
            
            TextField("", text: $text)
                .font(.pretendSemiBold12)
                .foregroundColor(.black)
                .disabled(isChecked)
                .onChange(of: text) { oldValue, newValue in
                    if newValue.count > 50 {
                        text = String(newValue.prefix(50))
                    }
                }
        }
    }
    
    private var moreButton: some View {
        Button {
            showActionSheet = true
        } label: {
            Image("more-btn")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var underLine: some View {
        Rectangle()
            .foregroundColor(.black)
            .frame(height: 1)
            .padding(.leading, 27)
            .padding(.trailing, 20)
    }
    
    private var todoActionSheet: some View {
        CustomActionSheet(
            title: "일정 옵션",
            primaryButtonTitle: "삭제하기",
            secondaryButtonTitle: "수정하기",
            primaryAction: {
                print("삭제 선택됨")
                showActionSheet = false
            },
            secondaryAction: {
                print("수정 선택됨")
                showActionSheet = false
            },
            primaryButtonColor: .systemError,
            primaryButtonTextColor: .grayWhite,
            secondaryButtonColor: .gray100,
            secondaryButtonTextColor: .black,
            secondaryButtonBorderColor: .gray100,
            secondaryButtonWidth: 175
        ) {
            TodoActionOptionsView()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Todo Action Options View

struct TodoActionOptionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            ForEach(TodoActionOption.allCases, id: \.self) { option in
                TodoActionOptionRow(option: option)
            }
        }
    }
}

struct TodoActionOptionRow: View {
    let option: TodoActionOption
    
    var body: some View {
        Button(action: option.action) {
            HStack(spacing: 12) {
                Image(option.iconName)
                    .frame(width: 20, height: 20)
                
                Text(option.title)
                    .font(.pretendSemiBold17)
                    .foregroundStyle(.black)
                
                Spacer()
            }
        }
    }
}

// MARK: - 사용 예시

struct TestView: View {
    @State private var todoText = ""
    @State private var isChecked = false

    var body: some View {
        ChecklistRow(isChecked: $isChecked, text: $todoText)
          
    }
}

#Preview {
    TestView()
}
