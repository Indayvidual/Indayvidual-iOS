import SwiftUI

struct CategoryRowView: View {
    let category: Category

    @State private var checklistItems: [CheckListItem] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.grayWhite)
//                    .fill(Color.black)
                    .frame(height: 39)

                NameField(category: category,
                          plusButtonAction: addChecklistItemIfAllowed)
                    .padding(.leading, 10)
            }.padding(.bottom,5)

            ForEach($checklistItems) { $item in
                ChecklistRow(isChecked: $item.isChecked, text: $item.text)
                    .padding(.bottom,7)
                    .padding(.horizontal,14)
            }
        }
    }

    private func addChecklistItemIfAllowed() {
        // 마지막 아이템이 있으면 텍스트 입력 여부 체크, 없으면 바로 추가
        if let lastItem = checklistItems.last {
            if !lastItem.text.isEmpty {
                checklistItems.append(CheckListItem(text: "", isChecked: false))
            }
        } else {
            checklistItems.append(CheckListItem(text: "", isChecked: false))
        }
    }
}

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
    CategoryRowView(category: Category(name: "샘플 카테고리", color: .yellow01))
}
