#' Solve SAT problems with the PicoSAT solver
#'
#' The solver takes a formula in conjunctive normal form and finds
#' a satisfiable assignment of the
#' literals or returns that the formula is not satisfiable.
#'
#' @param formula a list of integer vectors. Each vector is a clause.
#'               Each integer identifies a literal. No element must be 0.
#'               Negative integers are negated literals.
#' @param assumptions an optional integer vector. Assumptions are preset values for literals in your formula.
#'                   Each element correspond to a literal.
#'                   Negative literals are FALSE, positive TRUE.
#' @param verbosity_level either 0, 1, 2 where 2 is the most verbose log level.
#'
#' @examples
#' formula <- list(
#'  c(-1, 2), # 1 => 2
#'  c(-2, 3)  # 2 => 3
#' )
#' picosat_sat(formula, 1) # we set 1 to TRUE
#' @useDynLib rpicosat rpicosat_solve
#' @export
picosat_sat <- function(formula, assumptions = integer(0), verbosity_level = 0L) {
  stopifnot(is.list(formula), length(formula) > 0)

  literals <- unlist(lapply(formula, function(x) {
    if (any(x == 0) || anyNA(x)) stop("literals cannot be 0 or NA.", call. = FALSE)
    c(as.integer(x), 0L)
  }), use.names = FALSE)

  stopifnot(length(literals) > 0, is.integer(literals))
  stopifnot(length(assumptions) <= length(literals), is.numeric(literals))
  stopifnot(length(verbosity_level) == 1, verbosity_level >= 0L, verbosity_level <= 2L)

  if (!all(abs(assumptions) %in% abs(literals))) {
    stop("Some of your assumptions are not part of your literals", call. = FALSE)
  }

  # solve it
  res <- .Call("rpicosat_solve", as.integer(literals),
               as.integer(assumptions), as.integer(verbosity_level), PACKAGE = "rpicosat")

  # convert to a
  assignment <- res[[2]]
  if (anyNA(assignment)) {
    solution_vector <- NA
  } else {
    solution_vector <- stats::setNames(assignment > 0, abs(assignment))
  }
  out <- list(
    solution_status = if (res[[1]] == 10) "PICOSAT_SATISFIABLE"
                      else if (res[[1]] == 20) "PICOSAT_UNSATISFIABLE"
                      else "PICOSAT_UNKNOWN",
    solution = solution_vector
  )
  out
}
