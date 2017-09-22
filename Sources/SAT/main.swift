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

func main() throws {
    guard CommandLine.arguments.count > 1 else {
        usage()
    }

    let reader = DIMACSReader()

    let formula = try reader.read(filename: CommandLine.arguments[1])
    let start = DispatchTime.now()
    let isSat = formula.isSatisfiable()
    let end = DispatchTime.now()

    let milliseconds = (end.uptimeNanoseconds - start.uptimeNanoseconds) / NSEC_PER_MSEC
    print("Elapsed time: \(milliseconds)ms")

    print(isSat ? "SATISFIABLE" : "UNSATISFIABLE")
}

do {
    try main()
} catch {
    print("error: \(error)", to: &stderr)
}
