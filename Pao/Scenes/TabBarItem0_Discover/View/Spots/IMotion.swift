//
//  IMotion.swift
//  Pao
//
//  Created by kant on 25.04.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

protocol IMotion: class {
    var isTheWorldView: Bool { get set }
    var animationIdentifier: String? { get set }
    func set(_ playlist: PlayList)
}
