//
//  HabitFormView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/23/25.
//

import SwiftUI

struct HabitFormView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: MyHabitViewModel
    @State var colorViewModel: ColorViewModel
    @State private var showColorTable = false

    var body: some View {
        ZStack {
            Color.gray50
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                topBarView
                mainView
                Spacer()
            }
            .padding(.horizontal)
            .sheet(isPresented: $showColorTable) {
                sheetView
                    .presentationDragIndicator(.visible)
            }.menuIndicator(.visible)
        }
        .navigationBarBackButtonHidden(true)
        //.task사용 시 뷰가 그려진 후 아래 코드가 동작하여 UI가 한 박자 늦게 바뀜 -> .onAppear사용 : 뷰가 그려짐과 동시에 작동하여 UI가 어색하지 않음
        .onAppear {
            let currentColor = viewModel.colorName
            for i in colorViewModel.colors.indices {
                colorViewModel.colors[i].isSelected = (colorViewModel.colors[i].name == currentColor)
            }
        }
        .onDisappear {
            //단순 for문 동작이기 때문에 onDisappear는 필수적이진 않지만 있어서 나쁠 건 없다
            print("HabitFormView 닫힘")
        }
    }
    
    //TopBar를 .toolbarItem으로 수정하면 충돌 발생..
    var topBarView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }

            Spacer()

            Text(viewModel.isEditing ? "습관 수정" :"새로운 습관")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            Button {
                if let selectedColor = colorViewModel.colors.first(where: { $0.isSelected })?.name {
                    viewModel.colorName = selectedColor
                    viewModel.save()
                    dismiss()
                }
            } label: {
                Text("등록")
                    .font(.system(size: 16, weight: .medium))
                    .tint(.black)
            }
        }
        .padding(.top, 24)
    }
    
    var mainView: some View {
        VStack(spacing: 20) {
            TextField("습관 이름", text: $viewModel.title)
                .font(.pretendMedium14)
                .padding()
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )

            Button {
                self.showColorTable.toggle()
            } label: {
                HStack {
                    Text("색상 선택")
                        .font(.pretendMedium14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .tint(.black)
                    Spacer()
                    if let selectedColor = colorViewModel.colors.first(where: { $0.isSelected })?.name {
                        Circle()
                            .fill(Color(selectedColor))
                            .frame(width: 24, height: 24)
                    }
                    Image(systemName: "chevron.down")
                        .tint(.black)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .frame(height: 48)
            .tint(.gray200)
        }
    }
    
    var sheetView: some View {
        CustomActionSheet(
            title: "색상 선택",
            titleIcon: "paintpalette.fill",
            primaryButtonTitle: "선택 완료",
            secondaryButtonTitle: "초기화",
            primaryAction: {
                // 색상 저장 이후 toggle
                self.showColorTable.toggle()
            },
            secondaryAction: {
                // 초기 색상으로 자동 선택
                if let firstColor = colorViewModel.colors.first {
                    colorViewModel.colorSelection(for: firstColor.id)
                }
            }
        ) {
            VStack(alignment: .leading, spacing: 0) {
                ColorGridView(viewModel: colorViewModel)
            }
        }
    }
}

#Preview {
    HabitFormView(viewModel: MyHabitViewModel(sharedVM: CustomViewModel()), colorViewModel: ColorViewModel())
}
