//
//  Comparable.swift
//  OneMillionBot
//
//  Created by Adrián R on 1/6/21.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
