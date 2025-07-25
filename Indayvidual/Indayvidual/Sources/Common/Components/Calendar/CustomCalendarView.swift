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

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CalendarHeaderView(calendarViewModel: calendarViewModel)
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
        .shadow(color: Color.black.opacity(0.08), radius: 9.5, x: 2, y: 3)
    }

    @ViewBuilder
    private var calendarContentView: some View {
        if calendarViewModel.calendarMode == .month {
            MonthlyCalendarView(calendarViewModel: calendarViewModel, onDateSelected: onDateSelected)
        } else {
            WeeklyCalendarView(calendarViewModel: calendarViewModel, onDateSelected: onDateSelected)
        }
    }
}


// 캘린더 헤더
struct CalendarHeaderView: View {
    @ObservedObject var calendarViewModel: CustomCalendarViewModel

    private var yearAndMonth: (year: String, month: String) {
        let ym = calendarViewModel.getYearAndMonthString(currentDate: calendarViewModel.displayedMonthDate)
        guard ym.count >= 2 else {return (year: "", month: "")}
        return (year: ym[0], month: ym[1])
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

            toggleButton
            previousButton
            Spacer().frame(width: 7.8)
            nextButton
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
    var onDateSelected: ((Date) -> Void)?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 30), count: 7)
    private let rowCount: CGFloat = 6
    private let itemHeight: CGFloat = 30

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(calendarViewModel.extractDate(baseDate: calendarViewModel.displayedMonthDate)) { value in
                if value.day != -1 {
                    let isToday = Calendar.current.isDateInToday(value.date)
                    let isSelected = calendarViewModel.isSameDay(date1: value.date, date2: calendarViewModel.selectDate)

                    DateButton(
                        value: value,
                        isToday: isToday,
                        isSelected: isSelected,
                        onSelectDate: {
                            calendarViewModel.updateSelectedDate(value.date)
                            onDateSelected?(value.date)
                        },
                        markers: calendarViewModel.dateMarkers[Calendar.current.startOfDay(for: value.date)] ?? []
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
    var onDateSelected: ((Date) -> Void)?

    var body: some View {
        HStack(spacing: 15) {
            ForEach(getThisWeekDateValues()) { value in
                let isToday = Calendar.current.isDateInToday(value.date)
                let isSelected = calendarViewModel.isSameDay(date1: value.date, date2: calendarViewModel.selectDate)

                DateButton(
                    value: value,
                    isToday: isToday,
                    isSelected: isSelected,
                    onSelectDate: {
                        calendarViewModel.updateSelectedDate(value.date)
                        onDateSelected?(value.date)
                    },
                    markers: calendarViewModel.dateMarkers[Calendar.current.startOfDay(for: value.date)] ?? []
                )
            }
        }
    }

    private func getThisWeekDateValues() -> [DateValue] {
        let calendar = Calendar.current
        let selectedDate = calendarViewModel.selectDate
        let weekday = calendar.component(.weekday, from: selectedDate)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: selectedDate)!

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
 다른 뷰에서 CustomCalendarView를 사용하는 방법은 다음과 같습니다.

 1.  CustomCalendarViewModel 인스턴스 생성 및 전달
   - CustomCalendarView는 CustomCalendarViewModel을 @ObservedObject로 받습니다.
   - 따라서 캘린더를 사용하려는 뷰에서 CustomCalendarViewModel의 인스턴스를 생성하여 전달해야 합니다.
   - 예시
     struct MyCalendarUsageView: View {
         @StateObject private var calendarViewModel = CustomCalendarViewModel()

         var body: some View {
            CustomCalendarView(calendarViewModel: calendarViewModel)
        }
    }
 2. 날짜 선택 콜백 처리
   - onDateSelected 클로저를 통해 사용자가 캘린더에서 날짜를 선택했을 때의 이벤트 처리가 가능합니다.
   - 예시:
    CustomCalendarView(calendarViewModel: calendarViewModel) { selectedDate in
     // 선택된 날짜를 활용한 로직 구현
     // ex) 해당 날짜 일정 불러오기, UI 업데이트 등
    }
 
 3. 마커 추가
    - CustomCalendarViewModel의 addMarker(for: Date, color: Color) 함수를 사용하여 특정 날짜에 마커를 추가할 수 있습니다.
    - Date는 년, 월, 일만 고려되며, Color는 마커의 색상을 지정합니다.
    - 한 날짜에 최대 3개의 마커가 표시되며, 4개 이상 추가 시 가장 오래된 마커가 자동으로 제거됩니다.

     // 예시: 오늘 날짜에 빨간색 마커 추가
     // 즉, 아래 구문을 일정/투두/습관 생성 시에 호출하면됨
     calendarViewModel.addMarker(for: Date(), color: .red)

     // 예시: 특정 날짜에 파란색 마커 추가 (ViewModel의 dateFromYMD 유틸리티 함수 활용)
     // 즉, 아래 구문을 일정/투두/습관 생성 시에 호출하면됨
     let specificDate = calendarViewModel.dateFromYMD(year: 2025, month: 7, day: 20)
     calendarViewModel.addMarker(for: specificDate, color: .blue)

  4. 캘린더 모드 변경 (월/주):
     - 캘린더 헤더의 토글 버튼을 통해 월/주 모드를 전환할 수 있습니다.
     - calendarViewModel.toggleCalendarMode() 함수를 호출하여 프로그래밍 방식으로도 변경 가능합니다.

  5. 월/주 이동:
     - 캘린더 헤더의 이전/다음 버튼을 통해 월 또는 주를 이동할 수 있습니다.
     - calendarViewModel.moveCalendar(by: Int) 함수를 호출하여 프로그래밍 방식으로도 이동 가능합니다.
 */


#Preview {
    CustomCalendarView(calendarViewModel: CustomCalendarViewModel())
}

