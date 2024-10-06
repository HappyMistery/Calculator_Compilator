%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdbool.h>
  #include <unistd.h>
  #include <math.h>
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
}

%token <ival> INT BOOL
%token <fval> FLOAT PI E
%token <sval> STRING
%token COMM ID ASSIGN 
        ADD SUB MUL DIV MOD POW 
        HIG HEQ LOW LEQ EQU NEQ 
        NOT AND ORR

%type <ival> expr_int expr_bool
%type <fval> expr_float
%type <sval> expr_str

%start calculator

%%

calculator:
    stmnt_list
;

stmnt_list:
  expr '\n' stmnt_list
  | COMM '\n' stmnt_list
  | /* empty */               { /* Allow empty input */ }
;

expr:
    expr_arit
  | expr_bool   { printf("Result: %s\n", ($1 == 1) ? "true" : "false"); }
  | expr_str    { printf("Result: %s\n", $1); }
;

expr_arit:
    expr_int      { printf("Result: %d\n", $1); }
  | expr_float    { printf("Result: %g\n", $1); }
  | ID ASSIGN expr_int     { printf("%d\n", $3); }
  | ID ASSIGN expr_float   { printf("%g\n", $3); }
;

expr_int:
    INT       { $$ = $1; }
  | expr_int ADD expr_int { $$ = $1 + $3; }
  | expr_int SUB expr_int { $$ = $1 - $3; }
  | expr_int MUL expr_int { $$ = $1 * $3; }
  | expr_int MOD expr_int { $$ = $1 % $3; }
  | expr_int POW expr_int { $$ = pow($1,$3); }
  | '(' expr_int ')' { $$ = $2; }
;

expr_float:
    FLOAT     { $$ = $1; }
  | PI        { $$ = 3.14159; }
  | E         { $$ = 2.71828; }
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

expr_bool:
    BOOL      { $$ = $1; }
    | ID ASSIGN expr_bool   { $$ = $3; ($3 == 1) ? "true" : "false"; }
    | expr_int HIG expr_int { $$ = $1 > $3; }
    | expr_int HEQ expr_int { $$ = $1 >= $3; }
    | expr_int LOW expr_int { $$ = $1 < $3; }
    | expr_int LEQ expr_int { $$ = $1 <= $3; }
    | expr_int EQU expr_int { $$ = $1 == $3; }
    | expr_int NEQ expr_int { $$ = $1 != $3; }
    | expr_int HIG expr_float { $$ = $1 > $3; }
    | expr_int HEQ expr_float { $$ = $1 >= $3; }
    | expr_int LOW expr_float { $$ = $1 < $3; }
    | expr_int LEQ expr_float { $$ = $1 <= $3; }
    | expr_int EQU expr_float { $$ = $1 == $3; }
    | expr_int NEQ expr_float { $$ = $1 != $3; }
    | expr_float HIG expr_int { $$ = $1 > $3; }
    | expr_float HEQ expr_int { $$ = $1 >= $3; }
    | expr_float LOW expr_int { $$ = $1 < $3; }
    | expr_float LEQ expr_int { $$ = $1 <= $3; }
    | expr_float EQU expr_int { $$ = $1 == $3; }
    | expr_float NEQ expr_int { $$ = $1 != $3; }
    | expr_bool AND expr_bool { $$ = $1 && $3; }
    | expr_bool ORR expr_bool { $$ = $1 || $3; }
    | NOT expr_bool   { $$ = !$2; }
    | '(' expr_bool ')' { $$ = $2; }
;

expr_str:
    STRING    { $$ = $1; }
  | ID ASSIGN expr_str     { printf("%s\n", $3); }
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