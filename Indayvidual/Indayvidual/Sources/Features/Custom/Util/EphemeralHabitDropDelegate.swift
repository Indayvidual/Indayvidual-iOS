//
//  EphemeralHabitDropDelegate.swift
//  Indayvidual
//
//  Created by 김도연 on 8/11/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct EphemeralHabitDropDelegate: DropDelegate {
    let target: MyHabitModel
    @Binding var items: [MyHabitModel]
    @Binding var draggedItem: MyHabitModel?

    func validateDrop(info: DropInfo) -> Bool {
        true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func dropEntered(info: DropInfo) {
        guard
            let dragged = draggedItem,
            dragged.id != target.id,
            let from = items.firstIndex(where: { $0.id == dragged.id }),
            let to   = items.firstIndex(where: { $0.id == target.id })
        else { return }
        
        withAnimation(.easeInOut(duration: 0.15)) {
            items.move(fromOffsets: IndexSet(integer: from),
                       toOffset: to > from ? to + 1 : to)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
}
