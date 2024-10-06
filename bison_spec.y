%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdbool.h>
  int yylex(void);
  void yyerror(const char *s);

  extern int yylineno;
  #define YYERROR_VERBOSE 1
%}
%define parse.error verbose

%union {
    int ival;
    float fval;
    char* sval;
    int bval;
}

%token <ival> INT
%token <fval> FLOAT PI E
%token <sval> STRING
%token <bval> BOOL
%token COMM ID ASSIGN ADD SUB MUL DIV

%type <ival> expr_int
%type <fval> expr_float

%start calculator

%%

calculator:
    expr_list
;

expr_list:
  expr '\n' expr_list
  | /* empty */               { /* Allow empty input */ }
;

expr:
    expr_int     { printf("Result: %d\n", $1); }
  | expr_float   { printf("Result: %g\n", $1); }
  | ID ASSIGN expr_int     { printf("%d\n", $3); }
  | ID ASSIGN expr_float   { printf("%g\n", $3); }  
;

expr_int:
    INT       { $$ = $1; }
  | expr_int ADD expr_int { $$ = $1 + $3; }
  | expr_int SUB expr_int { $$ = $1 - $3; }
  | expr_int MUL expr_int { $$ = $1 * $3; }
  | '(' expr_int ')' { $$ = $2; }
;

expr_float:
    FLOAT     { $$ = $1; }
  | PI        { $$ = 3.141592653589; }
  | E         { $$ = 2.718281828459; }
  | expr_float ADD expr_float { $$ = $1 + $3; }
  | expr_float SUB expr_float { $$ = $1 - $3; }
  | expr_float MUL expr_float { $$ = $1 * $3; }
  | expr_float DIV expr_float { $$ = $1 / $3; }
  | expr_int ADD expr_float { $$ = $1 + $3; }
  | expr_int SUB expr_float { $$ = $1 - $3; }
  | expr_int MUL expr_float { $$ = $1 * $3; }
  | expr_int DIV expr_float { $$ = $1 / $3; }
  | expr_float ADD expr_int { $$ = $1 + $3; }
  | expr_float SUB expr_int { $$ = $1 - $3; }
  | expr_float MUL expr_int { $$ = $1 * $3; }
  | expr_float DIV expr_int { $$ = $1 / $3; }
  | expr_int DIV expr_int { $$ = (float)$1 / (float)$3; }
  | '(' expr_float ')' { $$ = $2; }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "\nError: %s in line %d\n", s, yylineno);
}

int main() {
    printf("Introdueix una expressió:\n");
    return(yyparse());
}

int yywrap() {
  return 1;
}