// Code from
// tools::package_native_routine_registration_skeleton(".")
#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* .Call calls */
extern SEXP rpicosat_solve(SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"rpicosat_solve", (DL_FUNC) &rpicosat_solve, 2},
    {NULL, NULL, 0}
};

void R_init_rpicosat(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
