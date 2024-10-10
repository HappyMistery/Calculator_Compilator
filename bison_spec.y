%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdbool.h>
  #include <unistd.h>
  #include <math.h>

  int yylex(void);
  /* int yydebug = 1; */
  void yyerror(const char *s);

  extern FILE *yyout;
  extern int yylineno;
  #define YYERROR_VERBOSE 1

  const double PI_CONST = 3.141592653589793;
  const double E_CONST = 2.718281828459045;
%}
%define parse.error verbose

%code requires {
  #include "dades.h"
  #include "funcions.h"
}

%union{
    struct {
        char *lexema;
        int lenght;
        int line;
        value_info id_val;
    } id;
    int ival;
    float fval;
    char* sval;
    value_info expr_val;
    void *sense_valor;
}

%token <id> ID
%token <ival> INT BOOL
%token <fval> FLOAT PI E SIN COS TAN
%token <sval> STRING
%token <sense_valor> COMM ASSIGN ENDLINE
                      ADD SUB MUL DIV MOD POW 
                      HIG HEQ LOW LEQ EQU NEQ 
                      NOT AND ORR
                      LEN SUBSTR
                      BIN OCT HEX DEC

%type <expr_val> expr arit_expr arit_term arit_pow arit_factor
%type <expr_val.sval> str_expr
%type <expr_val.bval> bool_expr bool_orr bool_and bool_not bool_term

%start calculator

%%

calculator:
    stmnt_list
;

stmnt_list:
  expr ENDLINE stmnt_list
  | ENDLINE stmnt_list
  | /* empty */               { /* Allow empty input */ }
;

expr:
    arit_expr   { 
                  if ($$.val_type == INT_TYPE) fprintf(yyout, "%d\n", $1.ival);
                  else if ($$.val_type == FLOAT_TYPE) fprintf(yyout, "%g\n", $1.fval);
                }
  | bool_expr   { $$.val_type = BOOL_TYPE; fprintf(yyout, "%s\n", ($1 == 1) ? "true" : "false"); }
  | str_expr    { fprintf(yyout, "%s\n", $1); }
  | ID ASSIGN str_expr    { fprintf(yyout, "%s\n", $3); }
;


arit_expr:
    LEN str_expr              { $$.val_type = INT_TYPE; $$.ival = strlen($2); }
  | SUB arit_expr             { 
                                if ($2.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = -$2.ival; }
                                else if ($2.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = -$2.fval; }
                              }
  | ADD arit_expr             { 
                                if ($2.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = +$2.ival; }
                                else if ($2.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = +$2.fval; }
                              }
  | arit_expr ADD arit_term   { 
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = $1.ival + $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = $1.ival + $3.fval; }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = $1.fval + $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = $1.fval + $3.fval;}
                                }
                              }
  | arit_expr SUB arit_term   { 
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = $1.ival - $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = $1.ival - $3.fval; }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = $1.fval - $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = $1.fval - $3.fval;}
                                }
                              }
  | arit_term            { $$ = $1; }
;

arit_term:
    arit_term MUL arit_pow    { 
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = $1.ival * $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = $1.ival * $3.fval; }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = $1.fval * $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = $1.fval * $3.fval;}
                                }
                              }
  | arit_term DIV arit_pow    { 
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = (float)$1.ival / (float)$3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = (float)$1.ival / $3.fval; }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = $1.fval / (float)$3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = $1.fval / $3.fval;}
                                }
                              }
  | arit_term MOD arit_pow    { 
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = $1.ival % $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = fmod($1.ival,$3.fval); }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = fmod($1.fval,$3.ival); }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = fmod($1.fval,$3.fval);}
                                }
                              }
  | arit_pow             { $$ = $1; } 
;

arit_pow:
    arit_pow ADD arit_factor  { 
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = pow($1.ival ,$3.ival); }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = pow($1.ival,$3.fval); }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = pow($1.fval,$3.ival); }
                                  else if ($3.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = pow($1.fval,$3.fval);}
                                }
                              }
  | arit_factor          { $$ = $1; }
;

arit_factor:
    INT         { $$.val_type = INT_TYPE; $$.ival = $1; }
  | FLOAT       { $$.val_type = FLOAT_TYPE; $$.fval = $1; }
  | PI          { $$.val_type = FLOAT_TYPE; $$.fval = PI_CONST; }
  | E           { $$.val_type = FLOAT_TYPE; $$.fval = E_CONST; }
  | SIN arit_expr   { 
                      if ($2.val_type == INT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = sin($2.ival * (PI_CONST / 180)); }
                      else if ($2.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = sin($2.fval * (PI_CONST / 180)); } 
                    }
  | COS arit_expr   { 
                      if ($2.val_type == INT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = cos($2.ival * (PI_CONST / 180)); }
                      else if ($2.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = cos($2.fval * (PI_CONST / 180)); } 
                    }
  | TAN arit_expr   { 
                      if ($2.val_type == INT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = tan($2.ival * (PI_CONST / 180)); }
                      else if ($2.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = tan($2.fval * (PI_CONST / 180)); } 
                    }
  | arit_expr    { $$ = $1; }
  | '(' arit_expr ')'    { $$ = $2; }
  | ID ASSIGN INT    { fprintf(yyout, "%d\n", $3); }
  | ID ASSIGN FLOAT  { fprintf(yyout, "%g\n", $3); }
;



bool_expr:
      arit_expr HIG arit_expr {
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.ival > $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.ival > $3.fval; }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.fval > $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.fval > $3.fval;}
                                }
                              }
    | arit_expr HEQ arit_expr {
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.ival >= $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.ival >= $3.fval; }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.fval >= $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.fval >= $3.fval;}
                                }
                              }
    | arit_expr LOW arit_expr {
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.ival < $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.ival < $3.fval; }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.fval < $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.fval < $3.fval;}
                                }
                              }
    | arit_expr LEQ arit_expr {
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.ival <= $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.ival <= $3.fval; }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.fval <= $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.fval <= $3.fval;}
                                }
                              }
    | arit_expr EQU arit_expr {
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.ival == $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.ival == $3.fval; }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.fval == $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.fval == $3.fval;}
                                }
                              }
    | arit_expr NEQ arit_expr {
                                if ($1.val_type == INT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.ival != $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.ival != $3.fval; }
                                }
                                else if ($1.val_type == FLOAT_TYPE) { 
                                  if ($3.val_type == INT_TYPE) { $$ = $1.fval != $3.ival; }
                                  else if ($3.val_type == FLOAT_TYPE) { $$ = $1.fval != $3.fval;}
                                }
                              }
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
  | str_expr ADD arit_expr     { char str[511]; sprintf(str, "%d", $3); $$ = strcat($1, str); }
  | arit_expr ADD str_expr     { char str[511]; sprintf(str, "%d", $1); $$ = strcat(str, $3); }
  | SUBSTR str_expr arit_expr arit_expr   { char str[511]; memcpy(str, $2+$3, $4); $$ = str; }
;

%%
int yywrap() {
  return 1;
}