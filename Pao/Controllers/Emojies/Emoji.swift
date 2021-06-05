//
//  Emoji.swift
//  Pao
//
//  Created by Rybolovleva Olga Viktorovna on 13.08.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

enum Emoji: Int, CaseIterable, Codable {

    typealias RawValue = Int

    case heart_eyes
    case gem
    case drooling_face
    case clap
    case round_pushpin
    
    var id: Int {
        switch self {
        case .heart_eyes: return 0
        case .gem: return 1
        case .drooling_face: return 2
        case .clap: return 3
        case .round_pushpin: return 4
        }
    }
    
    var code: String {
        switch self {
        case .heart_eyes: return "\u{1F60D}" //😍
        case .gem: return "\u{1F48E}" //💎
        case .drooling_face: return "\u{1F924}" //🤤
        case .clap: return "\u{1F44F}" //👏
        case .round_pushpin: return "\u{1F4CD}" //📍
        }
    }
    
    var text: String {
        switch self {
        case .heart_eyes:
            return L10n.EmojiList.HeartEyes.text
        case .gem:
            return L10n.EmojiList.Gem.text
        case .drooling_face:
            return L10n.EmojiList.DroolingFace.text
        case .clap:
            return L10n.EmojiList.Clap.text
        case .round_pushpin:
            return L10n.EmojiList.RoundPushpin.text
        }
    }

    var image: UIImage {
        switch self {
        case .heart_eyes:
            return Asset.Assets.Icons.emojiHeartEyes.image
        case .gem:
            return Asset.Assets.Icons.emojiDiamond.image
        case .drooling_face:
            return Asset.Assets.Icons.emojiDrooling.image
        case .clap:
            return Asset.Assets.Icons.emojiClappingHands.image
        case .round_pushpin:
            return Asset.Assets.Icons.emojiRedPin.image
        }
    }

    init?(rawValue: RawValue) {
        switch rawValue {
        case 0:
            self = .heart_eyes
        case 1:
            self = .gem
        case 2:
            self = .drooling_face
        case 3:
            self = .clap
        case 4:
            self = .round_pushpin
        default: return nil
        }
    }
}

extension Emoji: Comparable {
    static func < (lhs: Emoji, rhs: Emoji) -> Bool {
         lhs.id < rhs.id
    }
}
