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
        LEN SUBSTR
        BIN OCT HEX DEC

%type <ival> start_int_expr int_expr int_term int_pow int_factor bool_expr bool_orr bool_and bool_not bool_term
%type <fval> start_float_expr float_expr float_term float_pow float_factor
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
    start_int_expr      { printf("Result: %d\n", $1); }
  | start_float_expr    { printf("Result: %g\n", $1); }
  | ID ASSIGN int_expr    { printf("%d\n", $3); }
  | ID ASSIGN float_expr  { printf("%g\n", $3); }
;







start_int_expr:
    int_expr    { $$ = $1; }
;

int_expr:
    LEN str_expr            { $$ = strlen($2); }
  | SUB int_expr            { $$ = -$2; }
  | ADD int_expr            { $$ = +$2; }
  | int_expr ADD int_term   { $$ = $1 + $3; }
  | int_expr SUB int_term   { $$ = $1 - $3; }
  | int_term            { $$ = $1; }
;

int_term:
    int_term MUL int_pow    { $$ = $1 * $3; }
  | int_term MOD int_pow    { $$ = $1 % $3; }
  | int_pow             { $$ = $1; } 
;

int_pow:
    int_pow POW int_factor  { $$ = pow($1,$3); }
  | int_factor          { $$ = $1; }
;

int_factor:
    INT         { $$ = $1; }
  | int_expr    { $$ = $1; }
  | '(' int_expr ')'    { $$ = $2; }
;












start_float_expr:
    float_expr    { $$ = $1; }
;

float_expr:  
    SUB float_expr               { $$ = -$2; }
  | ADD float_expr              { $$ = +$2; }
  | float_expr ADD float_term   { $$ = $1 + $3; }
  | int_expr ADD float_term     { $$ = $1 + $3; }
  | float_expr ADD int_expr     { $$ = $1 + $3; }
  | float_expr SUB float_term   { $$ = $1 - $3; }
  | int_expr SUB float_term     { $$ = $1 - $3; }
  | float_expr SUB int_expr     { $$ = $1 - $3; }
  | float_term             { $$ = $1; }
;

float_term:
    float_term MUL float_pow    { $$ = $1 * $3; }
  | int_expr MUL float_pow      { $$ = $1 * $3; }
  | float_term MUL int_expr     { $$ = $1 * $3; }
  | float_term DIV float_pow    { $$ = $1 / $3; }
  | int_expr DIV int_expr       { $$ = (float)$1 / (float)$3; }
  | int_expr DIV float_pow      { $$ = $1 / $3; }
  | float_term DIV int_expr     { $$ = $1 / $3; }
  | float_term MOD float_pow    { $$ = fmod($1, $3); }
  | int_expr MOD float_pow      { $$ = fmod((float)$1, $3); }
  | float_term MOD int_expr     { $$ = fmod($1, (float)$3); }
  | float_pow             { $$ = $1; }
;

float_pow:
    float_pow POW float_factor  { $$ = pow($1,$3); }
  | int_expr POW float_factor   { $$ = pow($1,$3); }
  | float_pow POW int_expr      { $$ = pow($1,$3); }
  | float_factor          { $$ = $1; }
;

float_factor:
    FLOAT     { $$ = $1; }
  | PI        { $$ = PI_CONST; }
  | E         { $$ = E_CONST; }
  | SIN float_expr      { $$ = sin($2 * (PI_CONST / 180)); }
  | SIN start_int_expr  { $$ = sin($2 * (PI_CONST / 180)); }
  | COS float_expr      { $$ = cos($2 * (PI_CONST / 180)); }
  | COS start_int_expr  { $$ = cos($2 * (PI_CONST / 180)); }
  | TAN float_expr      { $$ = tan($2 * (PI_CONST / 180)); }
  | TAN start_int_expr  { $$ = tan($2 * (PI_CONST / 180)); }
  | float_expr          { $$ = $1; }
  | '(' float_expr ')'  { $$ = $2; }
;











bool_expr:
      start_int_expr HIG start_int_expr     { $$ = $1 > $3; }
    | start_int_expr HEQ start_int_expr     { $$ = $1 >= $3; }
    | start_int_expr LOW start_int_expr     { $$ = $1 < $3; }
    | start_int_expr LEQ start_int_expr     { $$ = $1 <= $3; }
    | start_int_expr EQU start_int_expr     { $$ = $1 == $3; }
    | start_int_expr NEQ start_int_expr     { $$ = $1 != $3; }
    | start_float_expr HIG start_float_expr { $$ = $1 > $3; }
    | start_float_expr HEQ start_float_expr { $$ = $1 >= $3; }
    | start_float_expr LOW start_float_expr { $$ = $1 < $3; }
    | start_float_expr LEQ start_float_expr { $$ = $1 <= $3; }
    | start_float_expr EQU start_float_expr { $$ = $1 == $3; }
    | start_float_expr NEQ start_float_expr { $$ = $1 != $3; }
    | start_int_expr HIG start_float_expr   { $$ = $1 > $3; }
    | start_int_expr HEQ start_float_expr   { $$ = $1 >= $3; }
    | start_int_expr LOW start_float_expr   { $$ = $1 < $3; }
    | start_int_expr LEQ start_float_expr   { $$ = $1 <= $3; }
    | start_int_expr EQU start_float_expr   { $$ = $1 == $3; }
    | start_int_expr NEQ start_float_expr   { $$ = $1 != $3; }
    | start_float_expr HIG start_int_expr   { $$ = $1 > $3; }
    | start_float_expr HEQ start_int_expr   { $$ = $1 >= $3; }
    | start_float_expr LOW start_int_expr   { $$ = $1 < $3; }
    | start_float_expr LEQ start_int_expr   { $$ = $1 <= $3; }
    | start_float_expr EQU start_int_expr   { $$ = $1 == $3; }
    | start_float_expr NEQ start_int_expr   { $$ = $1 != $3; }
    | bool_orr      { $$ = $1; }
;

bool_orr:
      bool_orr  ORR bool_and   { $$ = $1 || $3; }
    | bool_and      { $$ = $1; }
;

bool_and:
      bool_and AND bool_not   { $$ = $1 && $3; }
    | bool_not      { $$ = $1; }
;

bool_not:
      NOT bool_term   { $$ = !$2; }
    | bool_term       { $$ = $1; }
;

bool_term:
      BOOL      { $$ = $1; }
    | ID ASSIGN bool_expr   { $$ = $3; }
    | bool_expr             { $$ = $1; }
    | '(' bool_expr ')'     { $$ = $2; }
;













str_expr:
    STRING    { $$ = $1; }
  | str_expr ADD str_expr     { $$ = strcat($1, $3); }
  | str_expr ADD start_int_expr     { char str[511]; sprintf(str, "%d", $3); $$ = strcat($1, str); }
  | start_int_expr ADD str_expr     { char str[511]; sprintf(str, "%d", $1); $$ = strcat(str, $3); }
  | str_expr ADD start_float_expr   { char str[511]; sprintf(str, "%g", $3); $$ = strcat($1, str); }
  | start_float_expr ADD str_expr   { char str[511]; sprintf(str, "%g", $1); $$ = strcat(str, $3); }
  | SUBSTR str_expr start_int_expr start_int_expr   { char str[511]; memcpy(str, $2+$3, $4); $$ = str; }
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