//
//  HomeViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/25/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var showDatePickerSheet = false
    @Published var showCreateScheduleSheet = false
    @Published var showColorPickerSheet = false
}
