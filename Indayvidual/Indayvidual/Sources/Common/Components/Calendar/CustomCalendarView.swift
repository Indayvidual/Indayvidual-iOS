//
//  CustomCalendarView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/8/25.
//

import SwiftUI

struct CustomCalendarView: View {
    @ObservedObject var calendarViewModel: CustomCalendarViewModel
    var onDateSelected: ((Date) -> Void)?
    
    var showToggleButton: Bool = true      // 월/주 버튼 표시 여부
    var showShadow: Bool = true            // 쉐도우 표시 여부
    var showNavigationButtons: Bool = true   // 달(month) 이동 버튼 표시 여부
    var showMarkers: Bool = true             // 마커 표시 여부
    var initialMode: CalendarMode = .month   // 초기 모드 설정 (.month 또는 .week)
    
    init(
        calendarViewModel: CustomCalendarViewModel,
        showToggleButton: Bool = true,
        showShadow: Bool = true,
        showNavigationButtons: Bool = true,
        showMarkers: Bool = true,
        initialMode: CalendarMode = .month,
        onDateSelected: ((Date) -> Void)? = nil
    ) {
        self.calendarViewModel = calendarViewModel
        self.showToggleButton = showToggleButton
        self.showShadow = showShadow
        self.showNavigationButtons = showNavigationButtons
        self.showMarkers = showMarkers
        self.initialMode = initialMode
        self.onDateSelected = onDateSelected
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CalendarHeaderView(
                    calendarViewModel: calendarViewModel,
                    showToggleButton: showToggleButton,
                    showNavigationButtons: showNavigationButtons
                )
                WeekdayHeaderView()
                calendarContentView
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 23)
        }
        .frame(width: 320)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(red: 242/255, green: 242/255, blue: 247/255), lineWidth: 0.078)
        )
        .shadow(color: showShadow ? Color.black.opacity(0.08) : .clear, radius: 9.5, x: 2, y: 3)
        .task {
            calendarViewModel.calendarMode = initialMode
        }
    }

    @ViewBuilder
    private var calendarContentView: some View {
        if calendarViewModel.calendarMode == .month {
            MonthlyCalendarView(calendarViewModel: calendarViewModel,
                                showMarkers: showMarkers,
                                onDateSelected: onDateSelected)
        } else {
            WeeklyCalendarView(calendarViewModel: calendarViewModel,
                               showMarkers: showMarkers,
                               onDateSelected: onDateSelected)
        }
    }
}


// 캘린더 헤더
struct CalendarHeaderView: View {
    @ObservedObject var calendarViewModel: CustomCalendarViewModel
    var showToggleButton: Bool = true      // 월/주 버튼 표시 여부
    var showNavigationButtons: Bool = true // 달(month)이동 버튼 표시 여부

    private var yearAndMonth: (year: String, month: String) {
        let date = calendarViewModel.displayedMonthDate
        let year = date.toString(format: "yyyy")
        let month = date.toString(format: "M")
        return (year: year, month: month)
    }

    var body: some View {
        HStack {
            Text("\(yearAndMonth.month)월")
                .font(.pretendSemiBold16)
                .foregroundStyle(Color(.gray700))

            Spacer().frame(width: 8.9)

            Text("\(yearAndMonth.year)년")
                .font(.pretendSemiBold16)
                .foregroundStyle(Color(.gray700))
            Spacer()

            if showToggleButton {
                toggleButton
            }
            
            if showNavigationButtons {
                previousButton
                Spacer().frame(width: 7.8)
                nextButton
            }
        }
        .padding(.bottom, 20)
    }

    private var toggleButton: some View {
        Button {
            calendarViewModel.toggleCalendarMode()
        } label: {
            Text(calendarViewModel.calendarMode == .month ? "월" : "주")
                .font(.pretendSemiBold15)
                .frame(width: 29, height: 27)
                .foregroundStyle(Color(.gray900))
                .background(Color(.gray50))
                .cornerRadius(9)
        }
    }

    private var previousButton: some View {
        Button(action: {
            calendarViewModel.moveCalendar(by: -1)
        }) {
            Image(.mingcuteLeftFill)
        }
    }

    private var nextButton: some View {
        Button(action: {
            calendarViewModel.moveCalendar(by: 1)
        }) {
            Image(.mingcuteRightFill)
        }
    }
}


// 요일 헤더
struct WeekdayHeaderView: View {
    private let weekday = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    var body: some View {
        HStack(spacing: 26) {
            ForEach(weekday, id: \.self) { day in
                Text(day)
                    .font(.pretendMedium13)
                    .frame(width: 19, height: 16)
            }
        }
        .padding(.bottom, 20)
    }
}

// 월 캘린더
struct MonthlyCalendarView: View {
    @ObservedObject var calendarViewModel: CustomCalendarViewModel
    var showMarkers: Bool = true
    var onDateSelected: ((Date) -> Void)?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 30), count: 7)
    private let rowCount: CGFloat = 6
    private let itemHeight: CGFloat = 30

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(calendarViewModel.extractDate(baseDate: calendarViewModel.displayedMonthDate)) { value in
                if value.day != -1 {
                    let isToday = value.date.isToday
                    let isSelected = value.date.isSameDay(as: calendarViewModel.selectDate)

                    DateButton(
                        value: value,
                        isToday: isToday,
                        isSelected: isSelected,
                        onSelectDate: {
                            calendarViewModel.updateSelectedDate(value.date)
                            onDateSelected?(value.date)
                        },
                        markers: showMarkers ? (calendarViewModel.dateMarkers[value.date.startOfDay] ?? []) : []
                    )
                } else {
                    Color.clear.frame(width: 30, height: 30)
                }
            }
        }
        .frame(height: calculateMaxHeight())
    }

    private func calculateMaxHeight() -> CGFloat {
        (itemHeight * rowCount) + (rowCount - 1)
    }
}

// 주 캘린더
struct WeeklyCalendarView: View {
    @ObservedObject var calendarViewModel: CustomCalendarViewModel
    var showMarkers: Bool = true
    var onDateSelected: ((Date) -> Void)?

    var body: some View {
        HStack(spacing: 15) {
            ForEach(getThisWeekDateValues()) { value in
                let isToday = value.date.isToday
                let isSelected = value.date.isSameDay(as: calendarViewModel.selectDate)

                DateButton(
                    value: value,
                    isToday: isToday,
                    isSelected: isSelected,
                    onSelectDate: {
                        calendarViewModel.updateSelectedDate(value.date)
                        onDateSelected?(value.date)
                    },
                    markers: showMarkers ? (calendarViewModel.dateMarkers[value.date.startOfDay] ?? []) : []
                )
            }
        }
    }

    private func getThisWeekDateValues() -> [DateValue] {
        let calendar = Calendar.current
        let selectedDate = calendarViewModel.selectDate
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) else {
            return []
        }

        return (0..<7).compactMap { offset in
            if let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) {
                let day = calendar.component(.day, from: date)
                return DateValue(day: day, date: date)
            }
            return nil
        }
    }
}

// 일자 버튼
struct DateButton: View {
    var value: DateValue
    var isToday: Bool
    var isSelected: Bool
    var onSelectDate: () -> Void
    var markers: [Marker] // 마커 배열
    
    var body: some View {
        Button {
            onSelectDate()
        } label: {
            VStack(spacing: 2) {
                Text("\(value.day)")
                    .font(.pretendMedium13)
                    .foregroundColor(isSelected ? .white : Color(.gray900))
                    .frame(width: 30, height: 30)
                    .background(
                        Circle().fill(
                            isSelected ? .black :
                                (isToday ? Color(.gray200) : .clear)
                        )
                    )
                
                HStack(spacing: 1) { // 마커 표시를 위한 HStack
                    ForEach(markers.prefix(3), id: \.self) { marker in
                        Circle()
                            .fill(marker.color)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 4)
            }
            .frame(height: 30)
        }
    }
    
}

// MARK: - CustomCalendarView 사용 방법
/*
 CustomCalendarView를 다른 뷰에서 사용하는 방법 및 주요 옵션 설명입니다.

 1. CustomCalendarViewModel 인스턴스 생성 및 전달
    - CustomCalendarView는 CustomCalendarViewModel을 @ObservedObject로 받습니다.
    - 따라서 캘린더를 사용하려는 뷰에서 해당 ViewModel 인스턴스를 생성하여 전달해야 합니다.
    
    예시:
     struct MyCalendarUsageView: View {
         @StateObject private var calendarViewModel = CustomCalendarViewModel()

         var body: some View {
             CustomCalendarView(calendarViewModel: calendarViewModel)
         }
     }

 2. 날짜 선택 콜백 처리
    - onDateSelected 클로저를 통해 사용자가 날짜를 선택했을 때의 이벤트를 처리할 수 있습니다.
    
    예시:
     CustomCalendarView(calendarViewModel: calendarViewModel) { selectedDate in
         // ex) 선택된 날짜에 따라 일정 불러오기 등 처리
     }

 3. 마커 추가 및 표시 여부 설정
    - ViewModel의 addMarker(for:color:) 함수를 사용해 특정 날짜에 마커(도트)를 추가할 수 있습니다.
    - 한 날짜에 최대 3개까지 표시되며, 초과 시 가장 오래된 마커가 제거됩니다.

    - `showMarkers` 옵션을 사용해 캘린더에 마커 표시 여부를 제어할 수 있습니다.
      → `true`로 설정하면 마커가 보이고, `false`로 설정하면 마커가 화면에 표시되지 않습니다.
      → 기본값은 `true`입니다.

    예시:
     // 마커 추가
     calendarViewModel.addMarker(for: Date(), color: .red)

     // 마커 표시 비활성화 예시
     CustomCalendarView(calendarViewModel: calendarViewModel, showMarkers: false)

     // 마커 표시 활성화 (기본값)
     CustomCalendarView(calendarViewModel: calendarViewModel, showMarkers: true)

 4. 캘린더 모드 변경 (월 / 주)
    - 헤더의 토글 버튼을 통해 월간/주간 모드를 전환할 수 있습니다.
    - ViewModel의 toggleCalendarMode() 함수를 통해 프로그래밍 방식으로도 변경할 수 있습니다.

 5. 월 / 주 이동
    - 헤더의 좌우 화살표 버튼을 통해 이전/다음 월 또는 주로 이동합니다.
    - ViewModel의 moveCalendar(by:) 메서드로도 이동 가능.

 6. 커스터마이징 가능한 옵션들
    - `showToggleButton` (기본값: `true`)
      → 헤더 우측에 있는 "월/주" 전환 토글 버튼의 표시 여부를 제어합니다.
      → `false`로 설정 시 토글 버튼이 숨겨집니다.
    
    - `showShadow` (기본값: `true`)
      → 캘린더 뷰에 그림자 효과를 적용할지 여부를 제어합니다.
      → `false`로 설정하면 그림자가 제거되어 평면 UI처럼 보입니다.

    - `showNavigationButtons` (기본값: `true`)
      → 이전/다음 달(또는 주)로 이동하는 좌우 화살표 버튼의 표시 여부를 제어합니다.
      → `false`로 설정 시 버튼들이 숨겨집니다.

    - `showMarkers` (기본값: `true`)
      → 날짜 아래에 표시되는 마커(도트) 표시 여부를 제어합니다.
      → 필요에 따라 화면을 깔끔하게 하거나 마커를 숨기고 싶을 때 사용합니다.

    - `initialMode` (기본값: `.month`)
      → 캘린더가 처음 표시될 때의 모드를 지정합니다.
      → `.month` 또는 `.week` 값 사용 가능

    예시:
     CustomCalendarView(
         calendarViewModel: CustomCalendarViewModel(),
         showToggleButton: false,   // 토글 버튼 숨김
         showShadow: false,         // 그림자 제거
         showNavigationButtons: false, // 좌우 이동 버튼 숨김
         showMarkers: false,       // 마커 표시 안함
         initialMode: .week         // 처음에 주간 보기로 시작
     ) { selectedDate in
         print("선택된 날짜: \(selectedDate)")
     }

 */



#Preview {
    CustomCalendarView(calendarViewModel: CustomCalendarViewModel())
}
