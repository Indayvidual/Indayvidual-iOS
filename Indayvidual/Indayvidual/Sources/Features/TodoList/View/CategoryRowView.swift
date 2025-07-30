import SwiftUI

struct CategoryRowView: View {
    let category: Category

    @State private var checklistItems: [CheckListItem] = []
    @State private var isExpanded: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.grayWhite)
                    .frame(height: 39)
                HStack{
                    NameField(category: category,
                              plusButtonAction: addChecklistItemIfAllowed)
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
            if isExpanded {
                List {
                    ForEach(checklistItems.indices, id: \.self) { index in
                        ChecklistRow(
                            isChecked: Binding(
                                get: { checklistItems[index].isChecked },
                                set: { newValue in
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        checklistItems[index].isChecked = newValue
                                        sortItemsIfNeeded()
                                    }
                                }
                            ),
                            text: Binding(
                                get: { checklistItems[index].text },
                                set: { newValue in
                                    checklistItems[index].text = newValue
                                }
                            )
                        )
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal,10)
                        .padding(.vertical, 0)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onMove(perform: moveChecklistItem)
                }
                .listStyle(PlainListStyle())
                .frame(height: CGFloat(checklistItems.count * 50))
                .transition(.opacity)
                .clipped()
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
    
    private func moveChecklistItem(from source: IndexSet, to destination: Int) {
        withAnimation(.easeInOut(duration: 0.1)) {
            checklistItems.move(fromOffsets: source, toOffset: destination)
        }
        sortItemsImmediately()
    }
    
    private func sortItemsImmediately() {
        withAnimation(.easeInOut(duration: 0.2)) {
            checklistItems.sort { first, second in
                // 체크된 아이템이 위로 오도록 정렬
                if first.isChecked != second.isChecked {
                    return first.isChecked && !second.isChecked
                }
                return false
            }
        }
    }
    
    private func sortItemsIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sortItemsImmediately()
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
