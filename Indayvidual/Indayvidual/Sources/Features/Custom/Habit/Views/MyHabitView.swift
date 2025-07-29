//
//  MyHabitView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/18/25.
//

import SwiftUI
struct MyHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = HabitViewModel()
    @StateObject var colorViewModel = ColorViewModel()
    var sharedVM: CustomViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.gray50
                    .ignoresSafeArea()
                VStack {
                    topbar
                    // TODO: CalendarView 
                    if viewModel.habits.isEmpty {
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
                HabitFormView(viewModel: viewModel, colorViewModel: ColorViewModel())
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
            ForEach(viewModel.habits) { habit in
                HabitCardView(
                    habit: habit,
                    onToggle: { viewModel.toggleCompletion(for: habit) },
                    onEdit: {
                        // TODO: 습관 수정 화면 연결
                    },
                    onDelete: {
                        viewModel.deleteHabit(habit)
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
