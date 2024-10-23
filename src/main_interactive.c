#include <stdio.h>
#include "bison_spec.tab.h"

extern int yydebug;

int main() {
    yydebug = 1;
    printf("Introdueix una expressió:\n");
    return(yyparse());
}