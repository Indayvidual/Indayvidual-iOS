import SwiftUI

// 플로팅 버튼 컴포넌트
struct FloatingBtnTemplate: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image("plusBTN")
                .resizable()
                .frame(width: 56, height: 56)
        }
    }
}

struct FloatingButtonModifier: ViewModifier {
    let action: () -> Void
    let trailing: CGFloat
    let bottom: CGFloat
    let ignoreTabBar: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingBtnTemplate(action: action)
                        .padding(.trailing, trailing)
                        .padding(.bottom, bottom)
                }
            }
        }
    }
}


extension View {
    func floatingBtn(
        trailing: CGFloat = 13,
        bottom: CGFloat = 17,
        ignoreTabBar: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        modifier(FloatingButtonModifier(action: action, trailing: trailing, bottom: bottom, ignoreTabBar: ignoreTabBar))
    }
}

// MARK: - 커스텀 플로팅 버튼 사용 예시
// 네비게이션 라우터 사용하는 경우
enum Route: Hashable {
    case next
}

struct NextView: View {
    var body: some View {
        Text("예시용 다음 화면")
            .padding()
    }
}


struct testView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Text("플로팅 버튼 preview")
            }
            .floatingBtn {
                // 플로팅 버튼 클릭 시 라우팅되도록 이렇게 사용해주면 됩니다!
                path.append(Route.next)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .next:
                    NextView()
       
                  
                }
            }
        }
    }
}
#Preview("기본 사용") {
    testView()
}
