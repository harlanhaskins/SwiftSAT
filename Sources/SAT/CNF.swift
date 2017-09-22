//
//  CNF.swift
//  SAT
//
//  Created by Harlan Haskins on 9/21/17.
//  Copyright © 2017 Harlan Haskins. All rights reserved.
//

import Foundation

/// A boolean satisfiability formula in Conjunctive Normal Form.
/// A CNF formula is a formula of boolean variables of the following form
///
/// ```
/// (x1 | x2) & (!x2 | x3) & !x3
/// ```
/// where `|` represents the logical OR operation, `&` represents logical AND,
/// and `!` represents logical NOT.
///
/// A formula is considered satisfiable if there is a set of variables:
/// ```
/// [x1: true|false, ..., xn: true|false]
/// ```
/// for which the formula resolves to `true`.
struct CNF {
    /// The total number of variables in the formula.
    let numberOfVariables: Int

    /// All clauses in the formula. The satisfiability of the formula is
    /// the logical AND of each of these clauses.
    private(set) var clauses: [Clause]

    /// Assigns the variable to `true` in all clauses in the formula.
    ///
    /// - Parameter variable: The variable that's determined to be `true`.
    mutating func assign(_ variable: Variable) {
        var index = 0
        while index < clauses.count {
            let result = clauses[index].assign(variable)
            if case .clauseObviated = result {
                clauses.remove(at: index)
            } else {
                index += 1
            }
        }
    }

    /// Creates a new formula that is the result of assigning the specific
    /// variable to `true` in all clauses.
    ///
    /// - Parameter variable: The variable that's determined to be `true`.
    /// - Returns: A new CNF formula that assigns that variable to `true` in
    ///            all clauses where it appears.
    func assigning(_ variable: Variable) -> CNF {
        var copy = self
        copy.assign(variable)
        return copy
    }


    /// Propagates all unit variables through all clauses in the formula.
    /// For every clause, if the clause is a unit term, assign that variable
    /// through the remaining clauses. This will eliminate all instances of that
    /// variable throughout other clauses, and will only force that the variable
    /// evaluate to true for it to be satisfiable.
    mutating func unitPropagate() {
        for clause in clauses {
            if let term = clause.unitTerm {
                assign(term)
            }
        }
    }

    /// Creates a new CNF formula with unit propagation applied.
    ///
    /// - Returns: A new CNF formula that is the result of applying unit
    ///            propagation to the receiver.
    func unitPropagated() -> CNF {
        var copy = self
        copy.unitPropagate()
        return copy
    }

    /// Determines if all clauses in the formula are composed of a single
    /// pure variable.
    ///
    /// - Returns: `true` if the formula is trivially satisfiable.
    func isTriviallyConsistent() -> Bool {
        let unitTerms = Set(clauses.flatMap { $0.unitTerm })
        guard unitTerms.count == clauses.count else { return false }
        return !unitTerms.contains(where: { unitTerms.contains($0.inverse) })
    }


    /// Eliminates all 'pure' variables from all clauses in the formula.
    /// 'Pure' variables only ever appear as a literal or negation, but never
    /// both, across all clauses in the formula. They do not affect the
    /// satisfiability of the formula as a whole. This pass will go through the
    /// clauses and find all variables that only appear in one form, then remove
    /// them from all clauses in which they appear.
    mutating func eliminatePureVariables() {
        let allVariables = Set(clauses.flatMap { $0.variables })
        let pureVariables = allVariables.filter {
            !allVariables.contains($0.inverse)
        }
        var index = 0
        while index < clauses.count {
            clauses[index].eliminate(pureVariables: pureVariables)
            if clauses[index].variables.isEmpty {
                clauses.remove(at: index)
            } else {
                index += 1
            }
        }
    }

    /// Returns a copy of the formula after eliminating all pure variables
    /// from all clauses in the formula.
    ///
    /// - Returns: The formula with all pure variables eliminated.
    func eliminatingPureVariables() -> CNF {
        var copy = self
        copy.eliminatePureVariables()
        return copy
    }

    /// This is the implementation of DPLL that will iteratively
    /// reduce a formula until eventually deciding satisfiability. It employs
    /// two heuristics to simplify the search space:
    ///   - Unit propagation:
    ///     - If a variable appears on its own in a clause, then the variable
    ///       must be `true` in all other clauses it appears in. Therefore if,
    ///       in another clause, you see:
    ///         - the inverse of the variable, you can remove that variable from
    ///           that clause as it is always `false` and therefore has no
    ///           impact on the truthfulness of the clause
    ///         - the variable itself, then you can remove that clause entirely
    ///           from the search space as it's trivially going to be true
    ///           as the variable is considered true.
    ///   - Pure Literal Elimination:
    ///     - If a variable appears in any clause, and its inverse does not
    ///       appear in any other clause, then the variable is considered 'pure'
    ///       and it can be eliminated from every clause it appears in. This
    ///       is because it can either be true or false without affecting
    ///       the satisfiability of the rest of the formula.
    mutating private func runDPLL() -> Bool {
        guard clauses.count > 0 else { return true }
        if isTriviallyConsistent() { return true }
        if clauses.contains(where: { $0.variables.isEmpty }) { return false }
        unitPropagate()
        if clauses.contains(where: { $0.containsConflict }) { return false }
        eliminatePureVariables()
        if clauses.isEmpty { return true }
        guard let firstVariable = clauses.first?.variables.first else {
            return false
        }
        var leftAssigned = assigning(firstVariable)
        if leftAssigned.runDPLL() { return true }
        var rightAssigned = assigning(firstVariable.inverse)
        return rightAssigned.runDPLL()
    }

    /// Runs the DPLL satisfiability solving algorithm over the formula.
    func isSatisfiable() -> Bool {
        var copy = self
        return copy.runDPLL()
    }

    /// Converts the CNF formula to an equivalent DIMACS representation.
    func asDIMACS() -> String {
        var lines = ["p cnf \(numberOfVariables) \(clauses.count)"]
        lines += clauses.map { $0.asDIMACS() }
        return lines.joined(separator: "\n")
    }
}
