#' Solve SAT problems with the 'PicoSAT' solver
#'
#' The solver takes a formula in conjunctive normal form and finds
#' a satisfiable assignment of the
#' literals or returns that the formula is not satisfiable.
#'
#' @param formula a list of integer vectors. Each vector is a clause.
#'               Each integer identifies a literal. No element must be 0.
#'               Negative integers are negated literals.
#' @param assumptions an optional integer vector. Assumptions are fixed values for literals in your formula.
#'                   Each element corresponds to a literal.
#'                   Negative literals are FALSE, positive TRUE.
#'
#' @return a data.frame with two columns, variable and value. In case the solution status
#'   is not PICOSAT_SATISFIABLE the resulting data.frame has 0 rows.
#'   You can use `picosat_solution_status` to decide if the problem is satisfiable.
#'
#' @examples
#' # solve a boolean formula
#' # (not a or b) and (not b or c)
#' # each variable is an integer
#' # negations are negative integers
#' formula <- list(
#'  c(-1L, 2L),
#'  c(-2L, 3L)
#' )
#' res <- picosat_sat(formula)
#' picosat_solution_status(res)
#'
#' # set a variable to a fixed value
#' # e.g. a = TRUE and b = TRUE
#' res <- picosat_sat(formula, assumptions = c(1L, 2L))
#' picosat_solution_status(res)
#'
#' # get further information about the solution process
#' picosat_variables(res)
#' picosat_added_original_clauses(res)
#' picosat_decisions(res)
#' picosat_propagations(res)
#' picosat_visits (res)
#' picosat_seconds(res)
#'
#' @references
#' PicoSAT version 965 by Armin Biere: \url{http://fmv.jku.at/picosat/}
#'
#' A. Biere. PicoSAT Essentials. Journal on Satisfiability, Boolean Modeling and Computation, 4:75–97, 2008.
#'
#' @useDynLib rpicosat rpicosat_solve
#' @export
picosat_sat <- function(formula, assumptions = integer(0L)) {
  stopifnot(is.list(formula), length(formula) > 0L)

  literals <- as.integer(unlist(lapply(formula, function(x) {
    if (!is.numeric(x)) stop("Clauses must be integer vectors.", call. = FALSE)
    if (any(x == 0L) || anyNA(x)) stop("literals cannot be 0 or NA.", call. = FALSE)
    c(x, 0L)
  }), use.names = FALSE))

  stopifnot(length(literals) > 0L, is.integer(literals))
  stopifnot(length(assumptions) <= length(literals), is.numeric(literals))

  if (!all(abs(assumptions) %in% unique(abs(literals)))) {
    stop("Some of your assumptions are not part of your literals", call. = FALSE)
  }

  # solve it
  res <- .Call("rpicosat_solve", as.integer(literals),
               as.integer(assumptions), PACKAGE = "rpicosat")

  # convert to a
  assignment <- res[[2L]]
  if (!anyNA(assignment) && res[[1L]] == 10L) {
    solution_df <- data.frame(variable = as.integer(abs(assignment)),
                              value = assignment > 0L)
  } else {
    solution_df <- data.frame(variable = integer(0L),
                              value = logical(0L))
  }
  solution_status <- if (res[[1L]] == 10L) "PICOSAT_SATISFIABLE"
                      else if (res[[1L]] == 20L) "PICOSAT_UNSATISFIABLE"
                      else "PICOSAT_UNKNOWN"
  class(solution_df) <- c("picosat_solution", class(solution_df))
  attr(solution_df, "picosat_solution_status") <- solution_status

  # add statistics
  attr(solution_df, "picosat_variables") <- res[[3L]]
  attr(solution_df, "picosat_added_original_clauses") <- res[[4L]]
  attr(solution_df, "picosat_decisions") <- res[[5L]]
  attr(solution_df, "picosat_visits") <- res[[6L]]
  attr(solution_df, "picosat_propagations") <- res[[7L]]
  attr(solution_df, "picosat_seconds") <- res[[8L]]

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
  UseMethod("picosat_solution_status", x)
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
      paste0("Variables: ", picosat_variables(x), "\n",
             "Clauses: ", picosat_added_original_clauses(x), "\n")
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

#' The number of variables in a model
#'
#' @param x a picosat solution object
#' @return an integer vector of length 1
#' @export
#' @rdname picosat_variables
picosat_variables <- function(x) {
  UseMethod("picosat_variables")
}

#' @export
picosat_variables.picosat_solution <- function(x) {
  as.integer(attr(x, "picosat_variables", exact = TRUE))
}

#' The number of original clauses
#'
#' @param x a picosat solution object
#'
#' @return an integer vector of length 1
#' @export
#' @rdname picosat_added_original_clauses
picosat_added_original_clauses <- function(x) {
  UseMethod("picosat_added_original_clauses", x)
}

#' @export
picosat_added_original_clauses.picosat_solution <- function(x) {
  as.integer(attr(x, "picosat_added_original_clauses", exact = TRUE))
}


#' The number of decisions during a search
#'
#' @param x a picosat solution object
#' @return an integer vector of length 1
#' @export
#' @rdname picosat_decisions
picosat_decisions <- function(x) {
  UseMethod("picosat_decisions")
}

#' @export
picosat_decisions.picosat_solution <- function(x) {
  as.integer(attr(x, "picosat_decisions", exact = TRUE))
}


#' The number of visits during a search
#'
#' @param x a picosat solution object
#'
#' @return an integer vector of length 1
#' @export
#' @rdname picosat_visits
picosat_visits <- function(x) {
  UseMethod("picosat_visits")
}

#' @export
picosat_visits.picosat_solution <- function(x) {
  as.integer(attr(x, "picosat_visits", exact = TRUE))
}

#' The number of propagations during a search
#'
#' @param x a picosat solution object
#'
#' @return an integer vector of length 1
#' @export
#' @rdname picosat_propagations
picosat_propagations <- function(x) {
  UseMethod("picosat_propagations")
}

#' @export
picosat_propagations.picosat_solution <- function(x) {
  as.integer(attr(x, "picosat_propagations", exact = TRUE))
}

#' Time spent in `picosat_sat`
#'
#' @param x a picosat solution object
#'
#' @return a numeric vector of length 1
#' @export
#' @rdname picosat_seconds
picosat_seconds <- function(x) {
  UseMethod("picosat_seconds")
}

#' @export
picosat_seconds.picosat_solution <- function(x) {
  as.numeric(attr(x, "picosat_seconds", exact = TRUE))
}
