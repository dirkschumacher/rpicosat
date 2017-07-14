#include <R_ext/Rdynload.h>
#include "r_picosat.h"

static const R_CallMethodDef cMethods[] = {
  {"rpicosat_solve", (DL_FUNC) &rpicosat_solve, 3},
  {NULL, NULL, 0}
};

void R_init_myLib(DllInfo *info) {
  R_registerRoutines(info, NULL, cMethods, NULL, NULL);
  R_useDynamicSymbols(info, TRUE);
}
