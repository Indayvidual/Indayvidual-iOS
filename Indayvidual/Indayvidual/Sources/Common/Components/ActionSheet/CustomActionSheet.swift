import SwiftUI

struct CustomActionSheet<Content: View>: View {
    let title: String
    let titleIcon: String?
    let primaryButtonTitle: String
    let secondaryButtonTitle: String?
    let primaryAction: () -> Void
    let secondaryAction: (() -> Void)?
    let content: Content
    let showDivider: Bool
    
    //버튼 관련
    let primaryButtonColor: Color
    let primaryButtonTextColor: Color
    let secondaryButtonColor: Color
    let secondaryButtonTextColor: Color
    let secondaryButtonBorderColor: Color
    let buttonHeight: CGFloat
    let primaryButtonWidth: CGFloat?
    let secondaryButtonWidth: CGFloat?

    init(
        title: String = "액션시트 제목",
        titleIcon: String? = nil,
        primaryButtonTitle: String = "확인",
        secondaryButtonTitle: String? = "취소",
        primaryAction: @escaping () -> Void = { print("기본 액션") },
        secondaryAction: (() -> Void)? = { print("취소 액션") },
        showDivider: Bool = true,
        primaryButtonColor: Color = .black,
        primaryButtonTextColor: Color = .white,
        secondaryButtonColor: Color = .white,
        secondaryButtonTextColor: Color = .black,
        secondaryButtonBorderColor: Color = Color.gray.opacity(0.3),
        buttonHeight: CGFloat = 50,
        primaryButtonWidth: CGFloat? = nil,
        secondaryButtonWidth: CGFloat? = 150,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.titleIcon = titleIcon
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.showDivider = showDivider
        self.primaryButtonColor = primaryButtonColor
        self.primaryButtonTextColor = primaryButtonTextColor
        self.secondaryButtonColor = secondaryButtonColor
        self.secondaryButtonTextColor = secondaryButtonTextColor
        self.secondaryButtonBorderColor = secondaryButtonBorderColor
        self.buttonHeight = buttonHeight
        self.primaryButtonWidth = primaryButtonWidth
        self.secondaryButtonWidth = secondaryButtonWidth
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    if let titleIcon = titleIcon {
                        Image(systemName: titleIcon)
                            .foregroundColor(.black)
                    }
                    Text(title)
                        .font(.pretendSemiBold17)
                }
                Spacer()
            }
            .padding(.top, 33.65)
            .padding(.bottom, 15)
            .padding(.horizontal, 15.4)
            if showDivider {
                Divider()
                    .padding(.horizontal, 15.4)
                    .padding(.bottom, 20)
            }
            content
            
            Divider()
                .padding(.horizontal, 15.4)
                .padding(.bottom, 20)

            content.padding(.horizontal, 15)

            Spacer()
            
            HStack(spacing: 12) {
                if let secondaryButtonTitle = secondaryButtonTitle,
                   let secondaryAction = secondaryAction {
                    Button(action: secondaryAction) {
                        Text(secondaryButtonTitle)
                            .font(.pretendSemiBold15)
                            .foregroundColor(secondaryButtonTextColor)
                            .frame(width: secondaryButtonWidth)
                            .frame(height: buttonHeight)
                            .background(secondaryButtonColor)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(secondaryButtonBorderColor, lineWidth: 1)
                            )
                    }
                }
                
                Button(action: primaryAction) {
                    Text(primaryButtonTitle)
                        .font(.pretendSemiBold15)
                        .foregroundColor(primaryButtonTextColor)
                        .frame(width: primaryButtonWidth)
                        .frame(maxWidth: primaryButtonWidth == nil ? .infinity : nil)
                        .frame(height: buttonHeight)
                        .background(primaryButtonColor)
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

// MARK: - 커스텀 버튼 색상/크기 사용 예시
struct CustomButtonActionSheet: View {
    var body: some View {
        CustomActionSheet(
            title: "커스텀 버튼 색상과 크기",
            titleIcon: "paintbrush.fill",
            primaryButtonTitle: "저장",
            secondaryButtonTitle: "취소",
            primaryButtonColor: .blue,
            primaryButtonTextColor: .white,
            secondaryButtonColor: .gray.opacity(0.1),
            secondaryButtonTextColor: .blue,
            secondaryButtonBorderColor: .blue,
            buttonHeight: 60,
            secondaryButtonWidth: 120
        ) {
            VStack(alignment: .leading, spacing: 10) {
                Text("버튼 색상과 크기, 그리고 아이콘이 추가된 예시입니다.")
                Text("Primary 버튼은 파란색, Secondary 버튼도 파란색 테마로 변경되었습니다. primary가 넓은 버튼이에용")
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
         },
         primaryButtonColor: .green,
         primaryButtonTextColor: .white,
         secondaryButtonColor: .yellow,
         secondaryButtonTextColor: .black,
         secondaryButtonBorderColor: .orange,
         buttonHeight: 55
     ) {
         VStack(alignment: .leading) {
             Text("아이콘이 있는 액션시트는 위와 같이 사용하시면 됩니다")
         }
     }
 }
 */
#Preview {
    DefaultActionSheet()
    CustomButtonActionSheet()
}
