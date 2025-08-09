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
    @State private var editColorVM = ColorViewModel()
    @State var sharedVM: CustomViewModel                // 공유 뷰모델 설정
    @State private var selectedMode: HabitMode = .daily // 기본 .daily로 설정
    @State private var Change : Bool = false            // 습관 수정 NavigationView 트리거
    @State private var habit: MyHabitModel?             // 습관 수정 시 기존 습관 내용
    @State private var index: Int?                      // 습관 수정 시 기존 습관의 인덱스 번호

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
        .navigationDestination(isPresented: $Change) {  // 습관 수정 시 HabitFormView에 기존 습관 내용 전송
            HabitFormView(colorViewModel: editColorVM, viewModel: MyHabitViewModel(sharedVM: sharedVM, habit: habit, index: index))
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
        .task(id: selectedMode) {                       // .weekly 선택 시 주간 체크 다시 로드
            if selectedMode == .weekly {
                sharedVM.loadWeeklyChecks()
            }
        }
        .onDisappear {                                  // 부모 뷰로 돌아갈 때 weekly 새로고침
            sharedVM.loadWeeklyChecks()
        }
    }
    
    // 리스트 형식으로 현재 저장된 습관 출력
    var habitsListView: some View {
        ScrollView {
            VStack {
                ForEach(Array(sharedVM.habits.enumerated()), id: \.element.id) { index, habit in
                    HabitCardView(
                        calendarVM: calendarViewModel,
                        habit: habit,
                        onToggle: {
                            // ViewModel 인스턴스 중복 생성 방지 & toggleSelection func 호출
                            MyHabitViewModel(sharedVM: sharedVM).toggleSelection(at: index, date: calendarViewModel.selectDate.toAPIDateFormat())
                        },
                        onEdit: {
                            // 현재 습관 값 불러온 뒤 Change = true 설정하여 navigation
                            self.habit = habit
                            self.index = index
                            
                            // 현재 습관 색으로 선택 설정
                            let vm = ColorViewModel()
                            if let target = vm.colors.first(where: { $0.name == habit.colorName }) {
                                vm.colorSelection(for: target.id)
                            }
                            self.editColorVM = vm
                        
                            Change = true
                        },
                        onDelete: {
                            // ViewModel 인스턴스 중복 생성 방지 & delete func 호출
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
    
    // 뷰 하단 .daily, .weekly, .monthly 선택 탭
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
    
    // selecteedMode = .daily일 때
    var dailyView: some View {
        VStack {
            CustomCalendarView(
                        calendarViewModel: calendarViewModel,
                        showToggleButton: false,
                        initialMode: .week
                    )                                   // 현재 주차 캘린더 출력
            .padding(.top)
            completeView                                // 캘린더에서 선택한 날짜 및 완료 체크한 습관의 개수 출력
            habitsListView                              // 습관 리스트 뷰
        }
    }
    
    // selecteedMode = .weekly일 때
    var weeklyView: some View {
        VStack {
            ScrollView {
                WeeklyHabitView(                        // 현재 주차에 실행한 습관에 대한 뷰 ( 습관 완료한 날엔 습관 컬러에 맞춘 색 출력 )
                    sharedVM: sharedVM
                )
                .padding(12)
                .padding(.horizontal)
            }
        }
    }
    
    // selecteedMode = .monthly일 때
    var monthlyView: some View {
        VStack {
            CustomCalendarView(
                        calendarViewModel: calendarViewModel,
                        showToggleButton: false,
                    )                                   // 해당 월 캘린더 출력
            .padding(.top)
            completeView                                // 캘린더에서 선택한 날짜 및 완료 체크한 습관의 개수 출력
            habitsListView                              // 습관 리스트 뷰
        }
    }
    
    // 캘린더에서 선택한 날짜 및 완료 체크한 습관의 개수 출력
    var completeView: some View {
        let displayDate = calendarViewModel.selectDate.toDisplayFormat()    // 화면에 표시할 날짜 포맷
        let apiDate     = calendarViewModel.selectDate.toAPIDateFormat()    // API 호출에 쓸 날짜 포맷
        let isFuture    = Calendar.current.compare(                         // 오늘 00:00 기준으로 미래 여부 계산
                calendarViewModel.selectDate,
                to: Date(),
                toGranularity: .day
            ) == .orderedDescending
        let count = isFuture ? 0 : sharedVM.habitsSelectedCount             // 미래면 0, 아니면 실제 달성 개수

        return VStack(alignment: .leading) {
            Text(displayDate)                           // 캘린더에서 선택한 날짜, 요일 출력
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.pretendMedium15)
            Text("\(count)개의 활동을 달성했어요!")           // 체크 완료한 습관의 개수 출력
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
            guard !isFuture else { return }             // 미래 날짜면 API 호출 스킵
            MyHabitViewModel(sharedVM: sharedVM).fetchDailyChecks(Date: apiDate)
        }
    }
}

#Preview {
    MyHabitView(sharedVM: CustomViewModel.init())
}
