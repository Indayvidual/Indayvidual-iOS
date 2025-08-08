//
//  CustomView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/6/25.
//

import SwiftUI

struct CustomView: View{
    @Bindable private var vm = CustomViewModel()
    @State private var showAdd : Bool = false
    
    var body: some View{
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.gray500, .white]),
                               startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                VStack{
                    Topbar()
                    recordView
                        .padding(.bottom, 40)
                    Spacer()
                    myHabits
                }
                .padding(.horizontal)
            }
        }
    }
    
    var userRecord: some View {
        NavigationLink {
            RecordView(vm: MemoViewModel(sharedVM: vm), sharedVM: vm)
        } label: {
            HStack {
                Text("\(vm.name)님의 기록")
                    .font(.pretendBold24)
                    .foregroundStyle(.white)
                Image("Customdot")
                    .offset(y: -9)
                Spacer()
                Image(systemName: "chevron.right")
                    .bold()
            }
        }
        .tint(.white)
        .padding(.horizontal)
    }
    
    var recordView : some View {
        VStack {
            userRecord
                .padding(.vertical, 24)
            if vm.memosCount == 0 {
                Image("NoMemo")
                    .padding(.vertical)
            }
            else {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(vm.memos.indices, id: \.self) { index in
                            let memo = vm.memos[index]
                            NavigationLink {
                                AddMemoView(
                                    vm: MemoViewModel(
                                        sharedVM: vm,
                                        memo: memo,
                                        index: index
                                    )
                                )
                            } label: {
                                MemoView(memo: memo)
                                    .padding(16)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.automatic)
            }
        }
    }
    
    var myHabits: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .ignoresSafeArea(.all)
                .foregroundStyle(.white)
            
            VStack(alignment: .center) {
                NavigationLink {
                    MyHabitView(sharedVM: vm)
                } label: {
                    HStack {
                        Text("나의 습관")
                            .font(.pretendSemiBold22)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .bold()
                    }
                }
                .tint(.black)
                Spacer()
                if vm.habits.isEmpty {
                    Image("NoHabit")
                } else {
                    ScrollView {
                        WeeklyHabitView(showTitle: false, showShadow: false, sharedVM: vm)
                    }
                }
            }
            .padding(28)
        }
    }
}

#Preview{
    CustomView()
}
