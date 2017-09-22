//
//  DIMACSReader.swift
//  SATPackageDescription
//
//  Created by Harlan Haskins on 9/21/17.
//

import Foundation

/// A namespace for DIMACS-related functions.
struct DIMACSReader {
    /// A set of errors that can happen while parsing a DIMACS file.
    enum Error: Swift.Error {
        case unexpectedEntry(String)
        case invalidSpecificationLine(String)
    }

    /// Reads the DIMACS file at the provided filename into a CNF formula.
    func read(filename: String) throws -> CNF {
        let string = try String(contentsOf: URL(fileURLWithPath: filename),
                                encoding: .utf8)
        return try read(string)
    }

    func read(_ string: String) throws -> CNF {
        return try read(lines: string.split(separator: "\n"))
    }

    private func read(line: Substring) throws -> Clause {
        // Parse individual clauses as space-separated variable lists.
        var vars = Set<Variable>()
        let scanner = Scanner(string: String(line))
        scanner.charactersToBeSkipped = .whitespaces
        var n = 0
        while scanner.scanInt(&n) {
            if n == 0 { break }
            vars.insert(Variable(number: abs(n), isNegative: n < 0))
        }
        return Clause(variables: vars)
    }

    /// Parses the DIMACS file lines into a CNF formula.
    private func read(lines: [Substring]) throws -> CNF {
        var clauses = [Clause]()
        var numberOfVariables = 0
        for line in lines {
            // Skip comment lines.
            if line.hasPrefix("c") { continue }

            // Attempt to parse the `p cnf $numVariables $numClauses`
            // specification line.
            if line.hasPrefix("p cnf") {
                guard let varNumberString = line.split(separator: " ")
                                                .dropFirst(2).first,
                      let n = Int(varNumberString) else {
                    throw Error.invalidSpecificationLine(String(line))
                }
                numberOfVariables = n
                continue
            }

            clauses.append(try read(line: line))
        }
        return CNF(numberOfVariables: numberOfVariables, clauses: clauses)
    }
}
