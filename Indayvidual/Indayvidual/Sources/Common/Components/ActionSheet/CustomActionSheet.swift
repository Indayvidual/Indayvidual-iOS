import SwiftUI

struct CustomActionSheet<Content: View>: View {
    let title: String
    let titleIcon: String?
    let primaryButtonTitle: String
    let secondaryButtonTitle: String?
    let primaryAction: () -> Void
    let secondaryAction: (() -> Void)?
    let content: Content
    
    init(
        title: String = "액션시트 제목",
        titleIcon: String? = nil,
        primaryButtonTitle: String = "확인",
        secondaryButtonTitle: String? = "취소",
        primaryAction: @escaping () -> Void = { print("기본 액션") },
        secondaryAction: (() -> Void)? = { print("취소 액션") },
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.titleIcon = titleIcon
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    if let titleIcon = titleIcon {
                        Image(systemName: titleIcon)
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            .padding(.top, 33.65)
            .padding(.bottom, 15)
            .padding(.horizontal, 15.4)
            Divider()
                .padding(.horizontal, 15.4)
                .padding(.bottom, 20)
            content
            
            Spacer()
            
            HStack(spacing: 12) {
                if let secondaryButtonTitle = secondaryButtonTitle,
                   let secondaryAction = secondaryAction {
                    Button(action: secondaryAction) {
                        Text(secondaryButtonTitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 150)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                Button(action: primaryAction) {
                    Text(primaryButtonTitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 40)
            .padding(.horizontal, 15.4)
        }
        .background(Color.white)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - 사용 예시
struct DefaultActionSheet: View {
    var body: some View {
        CustomActionSheet {
            VStack(alignment: .leading, spacing: 0) {
                Text("이 부분에서 custom하시면 됩니다.")
            }
        }
    }
}

struct IconActionSheet: View {
    var body: some View {
        CustomActionSheet(
            title: "아이콘이 있는 경우의 액션시트",
            titleIcon: "bell.fill"
        ) {
            VStack(alignment: .leading, spacing: 0) {
                Text("아이콘이 있는 액션시트는 위와 같이 사용하시면 됩니다")
                  
            }
        }
    }
}
// MARK: - 실제 액션 시트에서 사용 예시
/*
 .sheet(isPresented: $isShowingActionSheet) {
     CustomActionSheet(
         title: "아이콘이 있는 경우의 액션시트",
         titleIcon: "bell.fill",
         primaryAction: {
             print("확인 버튼 클릭")
             isShowingActionSheet = false
         },
         secondaryAction: {
             print("취소 버튼 클릭")
             isShowingActionSheet = false
         }
     ) {
         VStack(alignment: .leading) {
             Text("아이콘이 있는 액션시트는 위와 같이 사용하시면 됩니다")
         }
     }
 }
 */
#Preview {
    DefaultActionSheet()
    IconActionSheet()
}

