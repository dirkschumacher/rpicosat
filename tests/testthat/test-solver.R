test_that("solves basic examples", {
  formula <- list(
      c(-1, 2), # 1 => 2
      c(-2, 3)  # 2 => 3
  )
  res <- picosat_sat(formula, 1)
  expect_equal("PICOSAT_SATISFIABLE", res$solution_status)
  expect_equal(c("1" = TRUE, "2" = TRUE, "3" = TRUE), res$solution)
})

test_that("handles unsatisfiable results", {
  formula <- list(
    c(1),
    c(-1)
  )
  res <- picosat_sat(formula)
  expect_equal("PICOSAT_UNSATISFIABLE", res$solution_status)
  expect_equal(NA, res$solution)
})

test_that("fails if a literal is 0", {
  expect_error(picosat_sat(list(c(1, 0))))
})

test_that("fails if a literal is NA", {
  expect_error(picosat_sat(list(c(1, NA))))
})

test_that("fails if assumption referes to a unknown literal", {
  expect_error(picosat_sat(list(c(1, 2)), 3))
})
