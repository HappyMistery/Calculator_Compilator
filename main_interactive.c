#include <stdio.h>
#include <math.h>
#include "bison_spec.tab.h"

extern int yydebug;

int main() {
    yydebug = 1;
    printf("Introdueix una expressió:%g\n", cos(2.718281828459045));
    return(yyparse());
}