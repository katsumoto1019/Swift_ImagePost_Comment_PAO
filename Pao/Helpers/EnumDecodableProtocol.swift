//
//  EnumDecodableProtocol.swift
//  Pao
//
//  Created by Rybolovleva Olga Viktorovna on 26.07.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

/// Help default decode value as enum case
protocol EnumDecodable: RawRepresentable, Decodable {
    static func defaultDecoderValue() throws -> Self
}

enum EnumDecodableError: Swift.Error {
    case noValue
}

extension EnumDecodable {
    static func defaultDecoderValue() throws -> Self {
        throw EnumDecodableError.noValue
    }
}

extension EnumDecodable where RawValue: Decodable {
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(RawValue.self)
        self = try Self(rawValue: value) ?? Self.defaultDecoderValue()
    }
}
