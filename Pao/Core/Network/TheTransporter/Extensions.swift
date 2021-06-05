//
//  Extensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 26/11/18.
//  Copyright © 2018 Exelia. All rights reserved.
//



extension String: PathVars {
    public var vars: [Any] {
        return [self];
    }
}

extension Array: PathVars where Element: StringProtocol {
    public var vars: [Any] {
        return self;
    }
}
