//
//  CustomView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/6/25.
//

import SwiftUI

struct CustomView: View{
    @Bindable var vm : CustomViewModel
    
    init() {
        self.vm = .init()
    }
    
    var body: some View{
        NavigationStack{
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
            }
        }
    }
    
    var userRecord: some View {
        NavigationLink {
            
        } label: {
            HStack {
                Text("\(vm.name)님의 기록")
                    .font(.pretendBold24)
                    .foregroundStyle(.white)
                
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .tint(.white)
        .padding(.horizontal)
    }
    
    var recordView : some View {
        VStack {
            userRecord
                .padding(.vertical, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0...10, id: \.self) { n in
                        MemoView()
                            .padding(32)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var myHabits: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .ignoresSafeArea(.all)
                .foregroundStyle(.white)
            
            VStack {
                NavigationLink {
                    
                } label: {
                    HStack {
                        Text("나의 습관")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                .tint(.black)
                
                Spacer()
                
                //습관 달력 만들고 추가 예정
                
            }
            .padding(28)
        }
    }
}

#Preview{
    CustomView()
}
