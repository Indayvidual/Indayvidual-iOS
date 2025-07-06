//
//  CustomView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/6/25.
//

import SwiftUI

struct CustomView: View{
    var body: some View{
        NavigationStack{
            VStack{
                Topbar()
                
                Spacer()
                
                Text("CustomView")
                
                Spacer()
            }
        }
    }
}

#Preview{
    CustomView()
}
