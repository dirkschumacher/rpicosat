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
  SEXP npropagations = PROTECT(allocVector(INTSXP, 1));
  INTEGER(npropagations)[0] = picosat_propagations(pico_ptr);
  SEXP ndecisions = PROTECT(allocVector(INTSXP, 1));
  INTEGER(ndecisions)[0] = picosat_decisions(pico_ptr);
  SEXP nvisits = PROTECT(allocVector(INTSXP, 1));
  INTEGER(nvisits)[0] = picosat_visits(pico_ptr);
  SEXP seconds = PROTECT(allocVector(REALSXP, 1));
  REAL(seconds)[0] = picosat_seconds(pico_ptr);

  picosat_reset(pico_ptr);

  // build return object
  SEXP solution_code = PROTECT(allocVector(INTSXP, 1));
  INTEGER(solution_code)[0] = res;
  SEXP out = PROTECT(allocVector(VECSXP, 6));
  SET_VECTOR_ELT(out, 0, solution_code);
  SET_VECTOR_ELT(out, 1, solution);
  SET_VECTOR_ELT(out, 2, npropagations);
  SET_VECTOR_ELT(out, 3, ndecisions);
  SET_VECTOR_ELT(out, 4, nvisits);
  SET_VECTOR_ELT(out, 5, seconds);
  UNPROTECT(6);
  return out;
}
