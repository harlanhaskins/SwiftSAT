//
//  main.swift
//  SAT
//
//  Created by Harlan Haskins on 9/21/17.
//  Copyright © 2017 Harlan Haskins. All rights reserved.
//

import Dispatch
import Foundation

extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        write(string.data(using: .utf8)!)
    }
}

var stderr = FileHandle.standardError

func usage() -> Never {
    print("usage: SAT <DIMACS file>", to: &stderr)
    exit(-1)
}

func time<T>(_ f: () throws -> T) rethrows -> (UInt64, T) {
    let start = DispatchTime.now()
    let v = try f()
    let end = DispatchTime.now()
    let milliseconds = (end.uptimeNanoseconds - start.uptimeNanoseconds) / NSEC_PER_MSEC
    return (milliseconds, v)
}

func main() throws {
    guard CommandLine.arguments.count > 1 else {
        usage()
    }

    let reader = DIMACSReader()

    let (parseTime, formula) = try time {
        try reader.read(filename: CommandLine.arguments[1])
    }
    let (solveTime, isSat) = time { formula.isSatisfiable() }

    print("Parse time: \(parseTime)ms")
    print("Solving time: \(solveTime)ms")

    print(isSat ? "SATISFIABLE" : "UNSATISFIABLE")
}

do {
    try main()
} catch {
    print("error: \(error)", to: &stderr)
}
