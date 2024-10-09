%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdbool.h>
  #include <unistd.h>
  #include <math.h>
  #include "symtab.h"

  int yylex(void);
  /* int yydebug = 1; */
  void yyerror(const char *s);

  extern int yylineno;
  #define YYERROR_VERBOSE 1

  const double PI_CONST = 3.141592653589793;
  const double E_CONST = 2.718281828459045;
%}
%define parse.error verbose

%union {
    int ival;
    float fval;
    char* sval;
}

%token <ival> INT BOOL
%token <fval> FLOAT PI E SIN COS TAN
%token <sval> STRING ID
%token COMM ASSIGN 
        ADD SUB MUL DIV MOD POW 
        HIG HEQ LOW LEQ EQU NEQ 
        NOT AND ORR

%type <ival> int_expr int_term int_pow int_factor bool_expr
%type <fval> float_expr float_term float_pow float_factor trig_expr
%type <sval> str_expr

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
    arit_expr
  | bool_expr   { printf("Result: %s\n", ($1 == 1) ? "true" : "false"); }
  | str_expr    { printf("Result: %s\n", $1); }
  | ID ASSIGN str_expr    { printf("%s\n", $3); }
;

arit_expr:
    int_expr      { printf("Result: %d\n", $1); }
  | float_expr    { printf("Result: %g\n", $1); }
  | ID ASSIGN int_expr    { printf("%d\n", $3); }
  | ID ASSIGN float_expr  { printf("%g\n", $3); }
;

int_expr:
    SUB int_term          { $$ = -$2; }
  | ADD int_term          { $$ = +$2; }
  | int_expr ADD int_term { $$ = $1 + $3; }
  | int_expr SUB int_term { $$ = $1 - $3; }
  | int_term         { $$ = $1; }
;

int_term:
    int_term MUL int_pow { $$ = $1 * $3; }
  | int_term MOD int_pow { $$ = $1 % $3; }
  | int_pow          { $$ = $1; } 
;

int_pow:
    int_pow POW int_factor { $$ = pow($1,$3); }
  | int_factor    { $$ = $1; }
;

int_factor:
    INT       { $$ = $1; }
  | int_expr  { $$ = $1; }
  | '(' int_expr ')'  { $$ = $2; }
;




float_expr:  
   SUB float_expr               { $$ = -$2; }
  | ADD float_expr              { $$ = +$2; }
  | float_expr ADD float_term   { $$ = $1 + $3; }
  | int_expr ADD float_term     { $$ = $1 + $3; }
  | float_expr ADD int_term     { $$ = $1 + $3; }
  | float_expr SUB float_term   { $$ = $1 - $3; }
  | int_expr SUB float_term     { $$ = $1 - $3; }
  | float_expr SUB int_term     { $$ = $1 - $3; }
  | float_term             { $$ = $1; }
;

float_term:
    float_term MUL float_pow   { $$ = $1 * $3; }
  | int_term MUL float_pow     { $$ = $1 * $3; }
  | float_term MUL int_pow     { $$ = $1 * $3; }
  | float_term DIV float_pow   { $$ = $1 / $3; }
  | int_term DIV int_pow       { $$ = (float)$1 / (float)$3; }
  | int_term DIV float_pow     { $$ = $1 / $3; }
  | float_term DIV int_pow     { $$ = $1 / $3; }
  | float_pow        { $$ = $1; }
;

float_pow:
    float_pow POW float_factor   { $$ = pow($1,$3); }
  | int_pow POW float_factor     { $$ = pow($1,$3); }
  | float_pow POW int_factor     { $$ = pow($1,$3); }
  | float_factor        { $$ = $1; }
;

float_factor:
    FLOAT     { $$ = $1; }
  | PI        { $$ = PI_CONST; }
  | E         { $$ = E_CONST; }
  | trig_expr           { $$ = $1; }
  | float_expr          { $$ = $1; }
  | '(' float_expr ')'  { $$ = $2; }
;

trig_expr:
    SIN float_expr    { $$ = sin($2 * (PI_CONST / 180)); }
  | SIN int_expr      { $$ = sin($2 * (PI_CONST / 180)); }
  | COS float_expr    { $$ = cos($2 * (PI_CONST / 180)); }
  | COS int_expr      { $$ = cos($2 * (PI_CONST / 180)); }
  | TAN float_expr    { $$ = tan($2 * (PI_CONST / 180)); }
  | TAN int_expr      { $$ = tan($2 * (PI_CONST / 180)); }
;

bool_expr:
    BOOL      { $$ = $1; }
    | ID ASSIGN bool_expr       { $$ = $3; }
    | '(' bool_expr ')'         { $$ = $2; }
    | NOT bool_expr             { $$ = !$2; }
    | bool_expr AND bool_expr   { $$ = $1 && $3; }
    | bool_expr ORR bool_expr   { $$ = $1 || $3; }
    | int_expr HIG int_expr     { $$ = $1 > $3; }
    | int_expr HEQ int_expr     { $$ = $1 >= $3; }
    | int_expr LOW int_expr     { $$ = $1 < $3; }
    | int_expr LEQ int_expr     { $$ = $1 <= $3; }
    | int_expr EQU int_expr     { $$ = $1 == $3; }
    | int_expr NEQ int_expr     { $$ = $1 != $3; }
    | int_expr HIG float_expr   { $$ = $1 > $3; }
    | int_expr HEQ float_expr   { $$ = $1 >= $3; }
    | int_expr LOW float_expr   { $$ = $1 < $3; }
    | int_expr LEQ float_expr   { $$ = $1 <= $3; }
    | int_expr EQU float_expr   { $$ = $1 == $3; }
    | int_expr NEQ float_expr   { $$ = $1 != $3; }
    | float_expr HIG int_expr   { $$ = $1 > $3; }
    | float_expr HEQ int_expr   { $$ = $1 >= $3; }
    | float_expr LOW int_expr   { $$ = $1 < $3; }
    | float_expr LEQ int_expr   { $$ = $1 <= $3; }
    | float_expr EQU int_expr   { $$ = $1 == $3; }
    | float_expr NEQ int_expr   { $$ = $1 != $3; }
;

str_expr:
    STRING    { $$ = $1; }
  | str_expr ADD str_expr   { $$ = strcat($1, $3); }
  | str_expr ADD int_expr   { char str[511]; sprintf(str, "%d", $3); $$ = strcat($1, str); }
  | int_expr ADD str_expr   { char str[511]; sprintf(str, "%d", $1); $$ = strcat(str, $3); }
  | str_expr ADD float_expr   { char str[511]; sprintf(str, "%g", $3); $$ = strcat($1, str); }
  | float_expr ADD str_expr   { char str[511]; sprintf(str, "%g", $1); $$ = strcat(str, $3); }
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