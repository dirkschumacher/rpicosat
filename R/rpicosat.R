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
#'
#' @return a data.frame with two columns, variable and value. In case the solution status
#'   is not PICOSAT_SATISFIABLE the resulting data.frame has 0 rows.
#'
#' @examples
#' formula <- list(
#'  c(-1, 2), # 1 => 2
#'  c(-2, 3)  # 2 => 3
#' )
#' picosat_sat(formula, 1) # we set 1 to TRUE
#' @useDynLib rpicosat rpicosat_solve
#' @export
picosat_sat <- function(formula, assumptions = integer(0)) {
  stopifnot(is.list(formula), length(formula) > 0)

  literals <- as.integer(unlist(lapply(formula, function(x) {
    if (!is.numeric(x)) stop("Clauses must be integer vectors.", call. = FALSE)
    if (any(x == 0) || anyNA(x)) stop("literals cannot be 0 or NA.", call. = FALSE)
    c(x, 0L)
  }), use.names = FALSE))

  stopifnot(length(literals) > 0, is.integer(literals))
  stopifnot(length(assumptions) <= length(literals), is.numeric(literals))

  if (!all(abs(assumptions) %in% unique(abs(literals)))) {
    stop("Some of your assumptions are not part of your literals", call. = FALSE)
  }

  # solve it
  res <- .Call("rpicosat_solve", as.integer(literals),
               as.integer(assumptions), PACKAGE = "rpicosat")

  # convert to a
  assignment <- res[[2]]
  if (!anyNA(assignment) && res[[1]] == 10) {
    solution_df <- data.frame(variable = as.integer(abs(assignment)),
                              value = assignment > 0)
  } else {
    solution_df <- data.frame(variable = integer(0),
                              value = logical(0))
  }
  solution_status <- if (res[[1]] == 10) "PICOSAT_SATISFIABLE"
                      else if (res[[1]] == 20) "PICOSAT_UNSATISFIABLE"
                      else "PICOSAT_UNKNOWN"
  class(solution_df) <- c("picosat_solution", class(solution_df))
  attr(solution_df, "picosat_solution_status") <- solution_status
  solution_df
}

#' Get the solution status
#'
#' @param x a solution from the solver
#'
#' @return character either PICOSAT_SATISFIABLE,
#'   PICOSAT_UNSATISFIABLE or PICOSAT_UNKNOWN
#'
#' @export
#' @rdname picosat_solution_status
picosat_solution_status <- function(x) {
  UseMethod("picosat_solution_status")
}

#' @export
#' @rdname picosat_solution_status
picosat_solution_status.picosat_solution <- function(x) {
  attr(x, "picosat_solution_status", exact = TRUE)
}

#' @export
format.picosat_solution <- function(x, ...) {
  solver_status <- picosat_solution_status(x)
  paste0(
    if (solver_status == "PICOSAT_SATISFIABLE") {
      paste0("Variables: ", length(unique(x$variable)), "\n")
    },
    "Solver status: ", solver_status
  )
}

#' @export
print.picosat_solution <- function(x, ...) {
  cat(format(x))
  cat("\n")
  invisible()
}
