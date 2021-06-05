//
//  CacherError.swift
//  Pao
//
//  Created by kant on 06.05.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

enum CacherError: Error {
    case failedDecode
    case failedTypeCasting
    case dataHasExpired
    case cacheIsNil
}
