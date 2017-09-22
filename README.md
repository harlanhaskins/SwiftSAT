# SAT

This is an implementation of a boolean satisfiability solver in Swift. It
solves problems of the form:

```
(x1 | x2) & (x2 | !x3) & (x4) & (x5 | !x2)
```

It uses the [DPLL Algorithm](https://en.wikipedia.org/wiki/DPLL_algorithm) to
iteratively reduce the clauses in the formula until converging on a formula
that is trivially either satisfiable or unsatisfiable.

The problem of boolean satisfiability is an NP-Complete problem, meaning that:
  - It is unknown if there are any polynomial-time (O(n^c) or smaller)
    algorithms that can solve this problem.
  - All other P or NP problems can be reduced to this problem.

# Author

Harlan Haskins ([@harlanhaskins](https://github.com/harlanhaskins))

# License

All code is released under the MIT license, a copy of which is available in
this repository.
