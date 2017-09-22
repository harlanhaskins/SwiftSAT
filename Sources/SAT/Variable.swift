//
//  Variable.swift
//  SAT
//
//  Created by Harlan Haskins on 9/21/17.
//

import Foundation

/// A Variable is a boolean variable that may exist either negated or as a
/// literal value.
///  and `!x1` corresponds to `.negation(1)`
struct Variable: Hashable {
    let number: Int
    let isNegative: Bool

    static func ==(lhs: Variable, rhs: Variable) -> Bool {
        return lhs.number == rhs.number && lhs.isNegative == rhs.isNegative
    }

    func evaluate(_ bool: Bool) -> Bool {
        return isNegative ? !bool : bool
    }

    var inverse: Variable {
        return Variable(number: number, isNegative: !isNegative)
    }

    var hashValue: Int {
        return number ^ (isNegative ? 0x10ba3b40 : ~0x10ba3b40)
    }

    var asDIMACS: String {
        var s = "\(number)"
        if isNegative {
            s.insert("-", at: s.startIndex)
        }
        return s
    }
}
