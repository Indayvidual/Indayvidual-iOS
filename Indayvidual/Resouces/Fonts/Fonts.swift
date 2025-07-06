//
//  Fonts.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/6/25.
//

import Foundation
import SwiftUI

extension Font {
    enum Pretend {
        case bold
        case semibold
        case medium
        case regular
        
        var value: String {
            switch self {
            case .bold: return "Pretendard-Bold"
            case .semibold: return "Pretendard-SemiBold"
            case .medium: return "Pretendard-Medium"
            case .regular: return "Pretendard-Regular"
            }
        }
    }

    static func pretend(_ type: Pretend, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }

    // MARK: - Bold
    static var pretendBold24: Font { .pretend(.bold, size: 24) }
    static var pretendBold13: Font { .pretend(.bold, size: 13) }

    // MARK: - SemiBold
    static var pretendSemiBold5: Font { .pretend(.semibold, size: 5) }
    static var pretendSemiBold8: Font { .pretend(.semibold, size: 8) }
    static var pretendSemiBold9: Font { .pretend(.semibold, size: 9) }
    static var pretendSemiBold10: Font { .pretend(.semibold, size: 10) }
    static var pretendSemiBold11: Font { .pretend(.semibold, size: 11) }
    static var pretendSemiBold12: Font { .pretend(.semibold, size: 12) }
    static var pretendSemiBold13: Font { .pretend(.semibold, size: 13) }
    static var pretendSemiBold14: Font { .pretend(.semibold, size: 14) }
    static var pretendSemiBold15: Font { .pretend(.semibold, size: 15) }
    static var pretendSemiBold16: Font { .pretend(.semibold, size: 16) }
    static var pretendSemiBold17: Font { .pretend(.semibold, size: 17) }
    static var pretendSemiBold18: Font { .pretend(.semibold, size: 18) }
    static var pretendSemiBold22: Font { .pretend(.semibold, size: 22) }

    // MARK: - Medium
    static var pretendMedium11: Font { .pretend(.medium, size: 11) }
    static var pretendMedium12: Font { .pretend(.medium, size: 12) }
    static var pretendMedium13: Font { .pretend(.medium, size: 13) }
    static var pretendMedium14: Font { .pretend(.medium, size: 14) }
    static var pretendMedium15: Font { .pretend(.medium, size: 15) }

    // MARK: - Regular
    static var pretendRegular10: Font { .pretend(.regular, size: 10) }
    static var pretendRegular11: Font { .pretend(.regular, size: 11) }
    static var pretendRegular12: Font { .pretend(.regular, size: 12) }
    static var pretendRegular13: Font { .pretend(.regular, size: 13) }
    static var pretendRegular14: Font { .pretend(.regular, size: 14) }
    static var pretendRegular15: Font { .pretend(.regular, size: 15) }
    static var pretendRegular23: Font { .pretend(.regular, size: 23) }
}
