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
  SEXP r_solution;
  if (res == PICOSAT_SATISFIABLE) {
    // get the variable solutions
    int nvars = picosat_variables(pico_ptr);
    r_solution = PROTECT(allocVector(INTSXP, nvars));
    int * solution = INTEGER(r_solution);
    for (int i = 1; i <= nvars; i++) {
      int val = picosat_deref(pico_ptr, i);
      solution[i - 1] = val * i;
    }
  } else {
    // set solution to NA
    r_solution = PROTECT(ScalarInteger(NA_INTEGER));
  }

  // extract statistics
  // number of variables
  SEXP no_vars = PROTECT(ScalarInteger(picosat_variables(pico_ptr)));

  // number of clauses
  SEXP no_clauses = PROTECT(ScalarInteger(picosat_added_original_clauses(pico_ptr)));

  // number of decisions
  SEXP no_dec = PROTECT(ScalarInteger(picosat_decisions(pico_ptr)));

  // number of visits
  SEXP no_visits = PROTECT(ScalarInteger(picosat_visits(pico_ptr)));

  // seconds it took so solve
  SEXP seconds = PROTECT(ScalarReal(picosat_seconds(pico_ptr)));

  // seconds it took so solve
  SEXP no_propagations = PROTECT(ScalarInteger(picosat_propagations(pico_ptr)));

  picosat_reset(pico_ptr);

  // build return object
  SEXP solution_code = PROTECT(ScalarInteger(res));
  SEXP out = PROTECT(allocVector(VECSXP, 8));
  SET_VECTOR_ELT(out, 0, solution_code);
  SET_VECTOR_ELT(out, 1, r_solution);
  SET_VECTOR_ELT(out, 2, no_vars);
  SET_VECTOR_ELT(out, 3, no_clauses);
  SET_VECTOR_ELT(out, 4, no_dec);
  SET_VECTOR_ELT(out, 5, no_visits);
  SET_VECTOR_ELT(out, 6, no_propagations);
  SET_VECTOR_ELT(out, 7, seconds);
  UNPROTECT(9);
  return out;
}
