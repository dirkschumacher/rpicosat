#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

extern SEXP rpicosat_solve(SEXP, SEXP, SEXP);

static const R_CallMethodDef cCalls[] = {
  {"rpicosat_solve", (DL_FUNC) &rpicosat_solve, 3},
  {NULL, NULL, 0}
};

void R_init_rpicosat(DllInfo *info) {
  R_registerRoutines(info, NULL, cCalls, NULL, NULL);
  R_useDynamicSymbols(info, FALSE);
}
