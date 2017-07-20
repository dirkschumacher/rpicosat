[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/dirkschumacher/rpicosat?branch=master&svg=true)](https://ci.appveyor.com/project/dirkschumacher/rpicosat) [![Travis-CI Build Status](https://travis-ci.org/dirkschumacher/rpicosat.svg?branch=master)](https://travis-ci.org/dirkschumacher/rpicosat) [![Coverage Status](https://img.shields.io/codecov/c/github/dirkschumacher/rpicosat/master.svg)](https://codecov.io/github/dirkschumacher/rpicosat?branch=master) [![CRAN Status](http://www.r-pkg.org/badges/version/rpicosat)](http://www.r-pkg.org/badges/version/rpicosat) [![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

<!-- README.md is generated from README.Rmd. Please edit that file -->
rpicosat
========

R bindings to the [PicoSAT solver release 965](http://fmv.jku.at/picosat/) by Armin Biere. The PicoSAT C code is distributed under a MIT style license and is bundled with this package.

Install
-------

``` r
devtools::install_github("dirkschumacher/rpicosat")
```

Example
-------

Suppose we want to test the following formula for satisfiability:

(*A* ⇒ *B*)∧(*B* ⇒ *C*)∧(*C* ⇒ *A*)

This can be formulated as a CNF (conjunctive normal form):

(¬*A* ∨ *B*)∧(¬*B* ∨ *C*)∧(¬*C* ∨ *A*)

``` r
library(rpicosat)
formula <- list(
  c(-1, 2),
  c(-2, 3),
  c(-3, 1)
)
picosat_sat(formula)
#> Variables: 3
#> Solver status: PICOSAT_SATISFIABLE
```

Every result is also a `tibble` so you can process the results with packages like `dplyr`.

We can also test for satisfiability if we assume that a certain literal is `TRUE` or `FALSE`

``` r
picosat_sat(formula, c(1)) # assume A is TRUE
#> Variables: 3
#> Solver status: PICOSAT_SATISFIABLE
```

``` r
picosat_sat(formula, c(1, -3)) # assume A is TRUE, but C is FALSE
#> Solver status: PICOSAT_UNSATISFIABLE
```
