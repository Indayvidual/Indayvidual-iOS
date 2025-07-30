//
//  MyHabitView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/18/25.
//

import SwiftUI
struct MyHabitView: View {
    @Environment(\.dismiss) private var dismiss
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
                            MemoListView
                        case .weekly:
                            Text("주간 습관 뷰")
                        case .monthly:
                            Text("월간 습관 뷰")
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
                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                    Text("\(sharedVM.name)님의 습관")
                        .font(.pretendBold24)
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
    
    var MemoListView: some View {
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
}

#Preview {
    MyHabitView(sharedVM: CustomViewModel.init())
}
