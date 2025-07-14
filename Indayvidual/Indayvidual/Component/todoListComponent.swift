import SwiftUI

struct TodoItem: Identifiable, Equatable {
    var id = UUID()
    var text: String
    var isChecked: Bool
    var isEditing: Bool = false
}

struct TodoListComponent: View {
    @Binding var items: [TodoItem]
    @State private var draggingItem: TodoItem?
    @FocusState private var focusedID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            ForEach($items, id: \ .id) { $item in
                TodoRow(
                    item: $item,
                    isFocused: focusedID == item.id,
                    onTap: {
                        item.isChecked.toggle()
                    },
                    onEdit: {
                        focusedID = item.id
                        item.isEditing = true
                    },
                    onMenu: {
                        // 메뉴 액션
                    }
                )
                .onDrag {
                    self.draggingItem = item
                    return NSItemProvider(object: item.text as NSString)
                }
                .onDrop(of: [.text], delegate: TodoDropDelegate(item: item, items: $items, draggingItem: $draggingItem))
            }
        }
        .padding(.vertical, 8)
    }
}

struct TodoRow: View {
    @Binding var item: TodoItem
    var isFocused: Bool
    var onTap: () -> Void
    var onEdit: () -> Void
    var onMenu: () -> Void
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(item.isChecked ? Color(.label) : Color(.systemGray5))
                    .frame(width: 28, height: 28)
                if item.isChecked {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .onTapGesture {
                onTap()
            }

            if item.isEditing {
                TextField("", text: $item.text, onCommit: {
                    item.isEditing = false
                })
                .focused($isTextFieldFocused)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("gray900"))
                .onAppear { isTextFieldFocused = true }
                .onSubmit { item.isEditing = false }
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(Color("gray900"))
                        .offset(y: 16),
                    alignment: .bottom
                )
            } else {
                Text(item.text)
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .medium))
                    .onTapGesture { onEdit() }
            }

            Spacer()
            Button(action: onMenu) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct TodoDropDelegate: DropDelegate {
    let item: TodoItem
    @Binding var items: [TodoItem]
    @Binding var draggingItem: TodoItem?
    
    func performDrop(info: DropInfo) -> Bool {
        self.draggingItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let dragging = draggingItem, dragging != item,
              let from = items.firstIndex(of: dragging),
              let to = items.firstIndex(of: item) else { return }
        withAnimation {
            items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }
}

// 미리보기 예시
struct TodoListComponent_Previews: PreviewProvider {
    @State static var items = [
        TodoItem(text: "할 일 입력", isChecked: true),
        TodoItem(text: "두 번째 할 일", isChecked: false)
    ]
    static var previews: some View {
        TodoListComponent(items: $items)
            .previewLayout(.sizeThatFits)
    }
} 
