//
//  HabitFormView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/23/25.
//

import SwiftUI

struct HabitFormView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: HabitViewModel
    @ObservedObject var colorViewModel: ColorViewModel
    @State private var showColorTable = false
    @State private var habitName: String = ""

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
    }
    
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

            Text("새로운 습관")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            Button {
                if let selectedColor = colorViewModel.colors.first(where: { $0.isSelected })?.name {
                    viewModel.addHabit(name: habitName, colorName: selectedColor)
                    dismiss()
                }
            } label: {
                Text("등록")
                    .font(.system(size: 16, weight: .medium))
                    .tint(.black)
            }
            .disabled(habitName.isEmpty)
        }
        .padding(.top, 24)
    }
    
    var mainView: some View {
        VStack(spacing: 20) {
            TextField("습관 이름", text: $habitName)
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
                    if let selectedColor = colorViewModel.colors.first(where: { $0.isSelected }) {
                        Circle()
                            .fill(Color(selectedColor.name))
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
    HabitFormView(viewModel: HabitViewModel(), colorViewModel: ColorViewModel())
}
