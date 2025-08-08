//
//  MyHabitView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/18/25.
//

import SwiftUI

struct MyHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var calendarViewModel = CustomCalendarViewModel()
    @State var sharedVM: CustomViewModel
    @State private var selectedMode: HabitMode = .daily
    @State private var Add : Bool = false
    @State private var habit: MyHabitModel?
    @State private var index: Int?

    var body: some View {
        ZStack {
            Color.gray50
                .ignoresSafeArea()
            VStack {
                switch selectedMode {
                case .daily:
                    dailyView
                case .weekly:
                    weeklyView
                case .monthly:
                    monthlyView
                }
                Spacer()
                selectMode
            }
        }
        .navigationDestination(isPresented: $Add) {
            HabitFormView(colorViewModel: ColorViewModel(), viewModel: MyHabitViewModel(sharedVM: sharedVM, habit: habit, index: index))
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                    .lineSpacing(4)
                    Text("\(sharedVM.name)님의 습관")
                        .font(.pretendBold24)
                    Image("Customdot")
                        .offset(y: -9)
                }
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                NavigationLink {
                    HabitFormView(colorViewModel: ColorViewModel(), viewModel: MyHabitViewModel(sharedVM: sharedVM))
                } label: {
                    Image("plusBTN")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
            })
        }
    }
    
    var habitsListView: some View {
        ScrollView {
            VStack {
                ForEach(Array(sharedVM.habits.enumerated()), id: \.element.id) { index, habit in
                    HabitCardView(
                        habit: habit,
                        onToggle: {
                            MyHabitViewModel(sharedVM: sharedVM)
                                .toggleSelection(at: index, date: calendarViewModel.selectDate.toAPIDateFormat())
                        },
                        onEdit: {
                            self.habit = habit
                            self.index = index
                            Add = true
                        },
                        onDelete: {
                            MyHabitViewModel(sharedVM: sharedVM).delete(at: index)
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
    
    var selectMode: some View {
        HStack(spacing: 0) {
            ForEach(HabitMode.allCases, id: \.self) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    Text(mode.rawValue.capitalized)
                        .font(.pretendSemiBold14)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(selectedMode == mode ? .gray500 : .white)
                        )
                        .padding(4)
                        .foregroundColor(selectedMode == mode ? .white : .black)
                        .animation(.easeInOut(duration: 0.2), value: selectedMode)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(.white)
        )
        .padding(.horizontal, 44)
        .padding(.vertical, 20)
    }
    
    var dailyView: some View {
        VStack {
            CustomCalendarView(
                        calendarViewModel: calendarViewModel,
                        showToggleButton: false,
                        initialMode: .week
                    )
            .padding(.top)
            completeView
            habitsListView
        }
    }
    
    var weeklyView: some View {
        VStack {
            ScrollView {
                WeeklyHabitView(sharedVM: sharedVM)
                    .padding(12)
                    .padding(.horizontal)
            }
        }
    }
    
    var monthlyView: some View {
        VStack {
            CustomCalendarView(
                        calendarViewModel: calendarViewModel,
                        showToggleButton: false,
                    )
            .padding(.top)
            completeView
            habitsListView
        }
    }
    
    var completeView: some View {
        let displayDate = calendarViewModel.selectDate.toDisplayFormat()
        let apiDate = calendarViewModel.selectDate.toAPIDateFormat()

        return VStack(alignment: .leading) {
            Text(displayDate)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.pretendMedium15)

            Text("\(sharedVM.habitsSelectedCount)개의 활동을 달성했어요!")
                .font(.pretendMedium12)
                .tint(.gray700)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .task(id: calendarViewModel.selectDate) {
            MyHabitViewModel(sharedVM: sharedVM).fetchDailyChecks(Date: apiDate)
        }
    }
}

#Preview {
    MyHabitView(sharedVM: CustomViewModel.init())
}
