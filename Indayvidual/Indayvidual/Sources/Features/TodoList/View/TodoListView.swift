import SwiftUI

enum Route1: Hashable {
    case next
}

struct TodoListView: View {
    @State private var path = NavigationPath()
    @State private var categories: [Category] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Topbar()
                Spacer().frame(height: 18)
                CustomCalendarView(calendarViewModel: CustomCalendarViewModel())
                Spacer().frame(height: 20)
                
                if categories.isEmpty {
                    VStack() {
                        Image("todo_checkbox")
                            .resizable()
                            .frame(width: 45, height: 45)
                        Spacer().frame(height: 16)
                        Text("등록된 할 일이 없습니다.")
                            .font(.pretendMedium14)
                            .foregroundStyle(.gray500)
                        Spacer().frame(height: 6)
                        Text("하단 + 버튼을 눌러서 카테고리를 생성해보세요.")
                            .font(.pretendMedium12)
                            .foregroundStyle(.gray500)
                    }
                    .padding(.horizontal,10)
                    .padding(.top,80)
                        
                } else {
                    ScrollView {
                        LazyVStack{
                            ForEach(categories, id: \.id) { category in
                                CategoryRowView(category: category)
                            }
                        }.padding(.horizontal,27)
                    }
                }
                
                Spacer()
            }
            .background(.gray50)
            .navigationDestination(for: Route1.self) { route in
                switch route {
                case .next:
                    TodoCategorySelectView(onCategoryAdded: { name, color in
                        addNewCategory(name: name, color: color)
                        path.removeLast()
                    })
                }
            }
        }
        .floatingBtn {
            path.append(Route1.next)
        }

    }
    private func addNewCategory(name: String, color: Color) {
        let newCategory = Category(name: name, color: color)
        categories.append(newCategory)
        print("새 카테고리 추가됨: \(name)")
    }
    
}

#Preview {
    TodoListView()
}
