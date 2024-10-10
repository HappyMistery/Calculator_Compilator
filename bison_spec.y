%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdbool.h>
  #include <unistd.h>
  #include <math.h>
  #include "dades.h"
  #include "funcions.h"
  

  int yylex(void);
  int yydebug = 1;
  void yyerror(const char *s);

  extern FILE *yyout;
  extern int yylineno;
  #define YYERROR_VERBOSE 1

  const double PI_CONST = 3.141592653589793;
  const double E_CONST = 2.718281828459045;

  void cast_vals_to_flt(value_info *op1, value_info *op2);
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

%type <expr_val> expr arit_expr arit_term arit_pow arit_trig arit_factor 
                  bool_expr bool_orr bool_and bool_not bool_term
                  str_expr

%start calculator

%%

calculator:
    stmnt_list
;

stmnt_list:
   expr ENDLINE stmnt_list
  | ENDLINE stmnt_list
  | expr ENDLINE
  | /* empty */               { /* Allow empty input */ }
;

expr:
    arit_expr   { 
                  if ($$.val_type == INT_TYPE) fprintf(yyout, "%d\n", $1.ival);
                  else if ($$.val_type == FLOAT_TYPE) fprintf(yyout, "%g\n", $1.fval);
                }
  | bool_expr   { $$.val_type = BOOL_TYPE; fprintf(yyout, "%s\n", ($1.bval == 1) ? "true" : "false"); }
  | str_expr    { $$.val_type = STRING_TYPE; fprintf(yyout, "%s\n", $1.sval); }
  | ID ASSIGN arit_expr   { 
                            if ($3.val_type == INT_TYPE) { 
                              printf("ID: %s pren per valor: %d\n", $1.lexema, $3.ival); fprintf(yyout, "%d\n", $3.ival);
                              $$.val_type = INT_TYPE; 
                              $$.ival = $3.ival; 
                            }
                            else { 
                              printf("ID: %s pren per valor: %g\n", $1.lexema, $3.fval); fprintf(yyout, "%g\n", $3.fval);
                              $$.val_type = FLOAT_TYPE;
                              $$.ival = $3.ival;
                            }
                          }
  | ID ASSIGN bool_expr   { 
                            printf("ID: %s pren per valor: %s\n", $1.lexema, ($3.bval == 1) ? "true" : "false"); fprintf(yyout, "%d\n", $3.bval);
                            $$.val_type = BOOL_TYPE; $$.bval = $3.bval;
                          }
  | ID ASSIGN str_expr    { 
                            printf("ID: %s pren per valor: %s\n", $1.lexema, $3.sval); fprintf(yyout, "%s\n", $3.sval);
                            $$.val_type = STRING_TYPE; $$.sval = $3.sval;
                          }
;


arit_expr:
    LEN str_expr              { $$.val_type = INT_TYPE; $$.ival = strlen($2.sval); }
  | SUB arit_expr             { 
                                if ($2.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = -$2.ival; }
                                else { $$.val_type = FLOAT_TYPE; $$.fval = -$2.fval; }
                              }
  | ADD arit_expr             { 
                                if ($2.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = +$2.ival; }
                                else { $$.val_type = FLOAT_TYPE; $$.fval = +$2.fval; }
                              }
  | arit_expr ADD arit_term   { 
                                if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { 
                                  cast_vals_to_flt(&$1, &$3); $$.val_type = FLOAT_TYPE; $$.fval = $1.fval + $3.fval;
                                } else { $$.val_type = INT_TYPE; $$.ival = $1.ival + $3.ival; }
                              }
  | arit_expr SUB arit_term   { 
                                if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { 
                                  cast_vals_to_flt(&$1, &$3); $$.val_type = FLOAT_TYPE; $$.fval = $1.fval - $3.fval;
                                } else { $$.val_type = INT_TYPE; $$.ival = $1.ival - $3.ival; }
                              }
  | arit_term
;

arit_term:
    arit_term MUL arit_pow    { 
                                if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { 
                                  cast_vals_to_flt(&$1, &$3); $$.val_type = FLOAT_TYPE; $$.fval = $1.fval * $3.fval;
                                } else { $$.val_type = INT_TYPE; $$.ival = $1.ival * $3.ival; }
                              }
  | arit_term DIV arit_pow    {  
                                cast_vals_to_flt(&$1, &$3); 
                                if ($3.fval == 0) yyerror("Division by zero error");
                                else { $$.val_type = FLOAT_TYPE; $$.fval = $1.fval / $3.fval;}
                              }
  | arit_term MOD arit_pow    { 
                                if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { 
                                  if (($3.val_type == FLOAT_TYPE && $3.fval == 0)  || ($3.val_type == INT_TYPE && $3.ival == 0)) yyerror("Modulo by zero error");
                                  else { cast_vals_to_flt(&$1, &$3); $$.val_type = FLOAT_TYPE; $$.fval = fmod($1.fval,$3.fval); }
                                } else { $$.val_type = INT_TYPE; $$.ival = $1.ival % $3.ival; }
                              }
  | arit_pow
;

arit_pow:
    arit_trig POW arit_pow  { 
                                if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { 
                                  cast_vals_to_flt(&$1, &$3); $$.val_type = FLOAT_TYPE; $$.fval = pow($1.fval,$3.fval);
                                } else { $$.val_type = INT_TYPE; $$.ival = pow($1.ival,$3.ival); }
                              }
  | arit_trig
;

arit_trig:
    SIN arit_factor       { 
                          cast_vals_to_flt(&$2, NULL);
                          $$.val_type = FLOAT_TYPE; 
                          $$.fval = sin($2.fval);
                        }
  | COS arit_factor       { 
                          cast_vals_to_flt(&$2, NULL); 
                          $$.val_type = FLOAT_TYPE; 
                          if(cos($2.fval) < 0.00000000001 && cos($2.fval) > -0.00000000001) $$.fval = 0;
                          else $$.fval = cos($2.fval);
                        }
  | TAN arit_factor       { 
                          cast_vals_to_flt(&$2, NULL);
                          if(cos($2.fval) < 0.00000000001) yyerror("Indefinition error");
                          else { 
                                  $$.val_type = FLOAT_TYPE;
                                  $$.fval = sin($2.fval)/cos($2.fval);
                          }
                        }
  | arit_factor
;

arit_factor:
    INT         { $$.val_type = INT_TYPE; $$.ival = $1; }
  | FLOAT       { $$.val_type = FLOAT_TYPE; $$.fval = $1; }
  | PI          { $$.val_type = FLOAT_TYPE; $$.fval = PI_CONST; }
  | E           { $$.val_type = FLOAT_TYPE; $$.fval = E_CONST; }
  | '(' arit_expr ')'   { 
                          $$.val_type = $2.val_type;
                          if ($2.val_type == INT_TYPE) $$.ival = $2.ival;
                          else $$.fval = $2.fval;
                        }
;



bool_expr:
      arit_expr HIG arit_expr { cast_vals_to_flt(&$1, &$3); $$.bval = $1.fval > $3.fval; }
    | arit_expr HEQ arit_expr { cast_vals_to_flt(&$1, &$3); $$.bval = $1.fval >= $3.fval; }
    | arit_expr LOW arit_expr { cast_vals_to_flt(&$1, &$3); $$.bval = $1.fval < $3.fval; }
    | arit_expr LEQ arit_expr { cast_vals_to_flt(&$1, &$3); $$.bval = $1.fval <= $3.fval; }
    | arit_expr EQU arit_expr { cast_vals_to_flt(&$1, &$3); $$.bval = $1.fval == $3.fval; }
    | arit_expr NEQ arit_expr { cast_vals_to_flt(&$1, &$3); $$.bval = $1.fval != $3.fval; }
    | bool_orr
;

bool_orr:
      bool_orr  ORR bool_and   { $$.bval = $1.bval || $3.bval; }
    | bool_and
;

bool_and:
      bool_and AND bool_not   { $$.bval = $1.bval && $3.bval; }
    | bool_not
;

bool_not:
      NOT bool_term   { $$.bval = !$2.bval; }
    | bool_term
;

bool_term:
      BOOL      { $$.val_type = BOOL_TYPE; $$.bval = $1; }
    | '(' bool_expr ')'     { $$.val_type = $2.val_type; $$.bval = $2.bval;}
;




str_expr:
    STRING    { $$.val_type = STRING_TYPE; $$.sval = $1; }
  | str_expr ADD str_expr     { $$.sval = strcat($1.sval, $3.sval); }
  | str_expr ADD arit_expr    { 
                                char str1[50];
                                if ($3.val_type == INT_TYPE) { sprintf(str1, "%d", $3.ival); $3.sval = str1; }
                                else { sprintf(str1, "%g", $3.fval); $3.sval = str1;}
                                $$.val_type = STRING_TYPE;
                                $$.sval = strcat($1.sval, $3.sval);
                              }
  | arit_expr ADD str_expr    { 
                                char str1[50];
                                if ($1.val_type == INT_TYPE) { sprintf(str1, "%d", $1.ival); $1.sval = str1; }
                                else { sprintf(str1, "%g", $1.fval); $1.sval = str1;}
                                $$.val_type = STRING_TYPE;
                                $$.sval = strcat($1.sval, $3.sval);
                              }
  | SUBSTR str_expr arit_expr arit_expr   { char str[strlen($2.sval)]; memcpy(str, $2.sval+$3.ival, $4.ival); $$.sval = str; }
;

%%

void cast_vals_to_flt(value_info *op1, value_info *op2) {
    if(op2 == NULL) {
      if (op1->val_type == INT_TYPE) op1->fval = (float)op1->ival;
    }
    else {
      if (op1->val_type == INT_TYPE) op1->fval = (float)op1->ival;
      if (op2->val_type == INT_TYPE) op2->fval = (float)op2->ival;
    }
}

int yywrap() {
  return 1;
}