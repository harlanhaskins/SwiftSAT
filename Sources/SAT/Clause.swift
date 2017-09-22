//
//  Clause.swift
//  SAT
//
//  Created by Harlan Haskins on 9/21/17.
//  Copyright © 2017 Harlan Haskins. All rights reserved.
//

import Foundation

/// A Clause represents the logical OR of a collection of variables.
struct Clause {
    /// The result of assigning a literal.
    enum AssignmentResult {
        /// The variable was removed from the clause, but the clause still has
        /// variables remaining.
        case removedVariable

        /// The variable was removed from the clause, and it was the only
        /// variable in the clause, thus obviating the need for the clause
        /// in the first place.
        case clauseObviated

        /// The variable did not appear in the clause, and so it remained
        /// unchanged.
        case clauseUnchanged
    }

    /// The set of variables in the clause. This is stored as a set because
    /// duplicate variables in a clause will fold down to a single instance
    /// of the variable, and using a set makes lookups O(1) amortized.
    private(set) var variables: Set<Variable>

    /// Whether this clause contains both a variable and its inverse, rendering
    /// it trivially false.
    var containsConflict: Bool {
        return variables.contains {
            variables.contains($0.inverse)
        }
    }

    /// If this clause has a single variable in it, returns that variable.
    /// Otherwise returns `nil`.
    var unitTerm: Variable? {
        guard let first = variables.first, variables.count == 1 else { return nil }
        return first
    }

    /// Removes the variables in the provided set from this clause's set of
    /// variables.
    /// - Parameter pureVariables: The set of variables to remove.
    mutating func eliminate(pureVariables: Set<Variable>) {
        variables.subtract(pureVariables)
    }

    /// Creates a version of this clause where the provided variables are
    /// removed.
    /// - Parameter pureVariables: The set of variables to remove.
    /// - Returns: A copy of this clause without the provided variables.
    func eliminating(pureVariables: Set<Variable>) -> Clause {
        var copy = self
        copy.eliminate(pureVariables: pureVariables)
        return copy
    }

    /// Assigns the specified variable to `true`, then simplifies the clause
    /// with that knowledge. Specifically:
    ///   - If the variable was not found in the clause, return the clause
    ///     unchanged.
    ///   - If the inverse of the variable was found, remove the variable from our set
    ///     and continue. This is because `(false | x) == x`.
    ///   - If the variable was found:
    ///     - If it was the only variable, leave the clause unchanged as that
    ///       is a unit term and affects the satisfiability of the whole
    ///       formula.
    ///     - Otherwise, the clause is trivially true and can be eliminated
    ///       from the whole formula.
    /// - Parameter variable: The variable to assume `true`.
    /// - Returns: A description of what change was made to the clause.
    mutating func assign(_ variable: Variable) -> AssignmentResult {
        guard let found = variables.first(where: { $0.number == variable.number }) else {
            return .clauseUnchanged
        }
        if found.isNegative == variable.isNegative {
            return variables.count == 1 ? .clauseUnchanged : .clauseObviated
        }
        variables.remove(variable)
        return .removedVariable
    }

    /// Returns the result of assigning the variable in the clause's set.
    /// If the change renders the clause useless, this function returns `nil`.
    /// - Parameter variable: The variable to consider `true`.
    /// - Returns: The clause after assigning the variable. If the clause was
    ///            rendered useless after assignment, then it returns `nil`.
    func assigning(_ variable: Variable) -> Clause? {
        var copy = self
        switch copy.assign(variable) {
        case .clauseUnchanged, .removedVariable: return copy
        case .clauseObviated: return nil
        }
    }

    /// Converts the clause to DIMACS representation.
    func asDIMACS() -> String {
        var vars = variables.map { $0.asDIMACS }
        vars.append("0")
        return vars.joined(separator: " ")
    }
}
