//
//  MyHabitView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/18/25.
//

import SwiftUI
struct MyHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var Add : Bool = false
    @State private var habit: MyHabitModel?
    @State private var index: Int?
    var sharedVM: CustomViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.gray50
                    .ignoresSafeArea()
                VStack {
                    topbar
                    // TODO: CalendarView 
                    if sharedVM.habits.isEmpty {
                        Spacer()
                        Image("NoHabit")
                        Spacer()
                    } else {
                        MemoListView
                        Spacer()
                    }
                }
            }
        }
        .navigationDestination(isPresented: $Add) {
            HabitFormView(viewModel: MyHabitViewModel(sharedVM: sharedVM, habit: habit, index: index), colorViewModel: ColorViewModel())
        }
        .navigationBarBackButtonHidden(true)
    }
    
    var topbar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
            }
            Text("\(sharedVM.name)님의 습관")
                .font(.pretendBold24)
            Spacer()
            NavigationLink {
                HabitFormView(viewModel: MyHabitViewModel(sharedVM: sharedVM), colorViewModel: ColorViewModel())
            } label: {
                Image("plusBTN")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
        }
        .font(.pretendSemiBold18)
        .tint(.black)
        .padding(.horizontal)
        .padding(.top, 24)
    }
    
    var MemoListView: some View {
        VStack {
            ForEach(Array(sharedVM.habits.enumerated()), id: \.element.id) { index, habit in
                HabitCardView(
                    habit: habit,
                    onToggle: {
                        sharedVM.habits[index].isSelected.toggle() // ✅ 직접 토글
                    },
                    onEdit: {
                        self.habit = habit
                        self.index = index
                        Add = true
                    },
                    onDelete: {
                        sharedVM.habits.remove(at: index) // ✅ 삭제
                    }
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .padding()
    }
}



#Preview {
    MyHabitView(sharedVM: CustomViewModel.init())
}
