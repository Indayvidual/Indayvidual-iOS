//
//  NetworkProvider.swift
//  Indayvidual
//
//  Created by 장주리 on 7/23/25.
//

import Moya

final class NetworkProvider {
    static let shared = NetworkProvider()
    let schoolInfoProvider = MoyaProvider<SchoolInfoTarget>()
    
    private init() {}
}