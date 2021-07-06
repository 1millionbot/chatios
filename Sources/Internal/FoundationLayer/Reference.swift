//
//  Reference.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 21/01/2021.
//

import Foundation

/// Wraps anything inside a reference type

final class Reference<Value> {
    init(value: Value) {
        self.value = value
    }

    var value: Value
}
