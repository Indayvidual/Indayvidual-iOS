//
//  DateValue.swift
//  Indayvidual
//
//  Created by 장주리 on 7/15/25.
//
import Foundation

struct DateValue: Identifiable, Equatable {
    let id = UUID()
    let day: Int
    let date: Date
}
