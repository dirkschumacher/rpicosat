#include "picosat.h"
#include <R.h>
#include <Rinternals.h>
#include "r_picosat.h"

SEXP rpicosat_solve(SEXP literals, SEXP assumptions) {
  PicoSAT *pico_ptr = picosat_init();

  // add the clauses
  int n_literals = length(literals);
  for (int i = 0; i < n_literals; i++) {
    picosat_add(pico_ptr, INTEGER(literals)[i]);
  }

  // add assumptions
  int n_assumptions = length(assumptions);
  for (int i = 0; i < n_assumptions; i++) {
    picosat_assume(pico_ptr, INTEGER(assumptions)[i]);
  }

  // solve it
  int res = picosat_sat(pico_ptr, -1);
  SEXP solution;
  if (res == PICOSAT_SATISFIABLE) {
    // get the variable solutions
    int nvars = picosat_variables(pico_ptr);
    solution = PROTECT(allocVector(INTSXP, nvars));
    for (int i = 1; i <= nvars; i++) {
      int val = picosat_deref(pico_ptr, i);
      INTEGER(solution)[i - 1] = val * i;
    }
    UNPROTECT(1);
  } else {
    // set solution to NA
    solution = PROTECT(allocVector(INTSXP, 1));
    INTEGER(solution)[0] = NA_INTEGER;
    UNPROTECT(1);
  }

  // extract statistics
  // number of variables
  SEXP no_vars = PROTECT(allocVector(INTSXP, 1));
  INTEGER(no_vars)[0] = picosat_variables(pico_ptr);
  UNPROTECT(1);

  // number of clauses
  SEXP no_clauses = PROTECT(allocVector(INTSXP, 1));
  INTEGER(no_clauses)[0] = picosat_added_original_clauses(pico_ptr);
  UNPROTECT(1);

  // number of decisions
  SEXP no_dec = PROTECT(allocVector(INTSXP, 1));
  INTEGER(no_dec)[0] = picosat_decisions(pico_ptr);
  UNPROTECT(1);

  // number of visits
  SEXP no_visits = PROTECT(allocVector(INTSXP, 1));
  INTEGER(no_visits)[0] = picosat_visits(pico_ptr);
  UNPROTECT(1);

  // seconds it took so solve
  SEXP seconds = PROTECT(allocVector(REALSXP, 1));
  REAL(seconds)[0] = picosat_seconds(pico_ptr);
  UNPROTECT(1);

  // seconds it took so solve
  SEXP no_propagations = PROTECT(allocVector(INTSXP, 1));
  INTEGER(no_propagations)[0] = picosat_propagations(pico_ptr);
  UNPROTECT(1);

  picosat_reset(pico_ptr);

  // build return object
  SEXP solution_code = PROTECT(allocVector(INTSXP, 1));
  INTEGER(solution_code)[0] = res;
  SEXP out = PROTECT(allocVector(VECSXP, 8));
  SET_VECTOR_ELT(out, 0, solution_code);
  SET_VECTOR_ELT(out, 1, solution);
  SET_VECTOR_ELT(out, 2, no_vars);
  SET_VECTOR_ELT(out, 3, no_clauses);
  SET_VECTOR_ELT(out, 4, no_dec);
  SET_VECTOR_ELT(out, 5, no_visits);
  SET_VECTOR_ELT(out, 6, no_propagations);
  SET_VECTOR_ELT(out, 7, seconds);
  UNPROTECT(2);
  return out;
}
