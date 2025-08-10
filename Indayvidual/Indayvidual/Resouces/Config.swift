//
//  Config.swift
//  Indayvidual
//
//  Created by 김도연 on 7/28/25.
//


import Foundation

enum Config {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist cannot be found")
        }
        return dict
    }()
    
    static let baseURL: String = {
        guard let baseURL = Config.infoDictionary["BASE_URL"] as? String else {
            fatalError("BaseURL not found")
        }
        return baseURL
    }()
}
