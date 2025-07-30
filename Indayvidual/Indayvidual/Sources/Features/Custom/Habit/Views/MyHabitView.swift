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
    @State private var selectedMode: HabitMode.Mode = .daily
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
                    if sharedVM.habits.isEmpty {
                        Spacer()
                        Image("NoHabit")
                        Spacer()
                    } else {
                        switch selectedMode {
                        case .daily:
                            dailyView
                        case .weekly:
                            weeklyView
                        case .monthly:
                            monthlyView
                        }
                    }
                    Spacer()
                    selectMode
                }
            }
        }
        .navigationDestination(isPresented: $Add) {
            HabitFormView(viewModel: MyHabitViewModel(sharedVM: sharedVM, habit: habit, index: index), colorViewModel: ColorViewModel())
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
                    HabitFormView(viewModel: MyHabitViewModel(sharedVM: sharedVM),colorViewModel: ColorViewModel())
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
                            sharedVM.habits[index].isSelected.toggle()
                        },
                        onEdit: {
                            self.habit = habit
                            self.index = index
                            Add = true
                        },
                        onDelete: {
                            sharedVM.habits.remove(at: index)
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
            ForEach(HabitMode.Mode.allCases, id: \.self) { mode in
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
        VStack(alignment: .leading) {
            Text("\(7)월 \(31)일 \("목")요일") //TODO: 날짜 커스텀 캘린더에서 어떻게 받아오는지 여쭤보기
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
    }
}

#Preview {
    MyHabitView(sharedVM: CustomViewModel.init())
}
