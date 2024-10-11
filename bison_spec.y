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
                      OP CP

%type <expr_val> stmnt expr mult_expr exp_expr trig_expr term_expr
                  bool_expr bool_orr bool_and bool_not bool_term
                  str_expr

%start calculator

%%

calculator:
    stmnt_list
;

stmnt_list:
   stmnt ENDLINE stmnt_list
  | ENDLINE stmnt_list
  | /* empty */               { /* Allow empty input */ }
;

stmnt:
    ID ASSIGN expr  { 
                      $1.id_val.val_type = $3.val_type;   /* Match the ID type to the asssignation's */
                      if ($3.val_type == INT_TYPE) {      /* Assign an Integer to the ID */
                        printf("[%s] %s = %d\n", type_to_str($1.id_val.val_type), $1.lexema, $3.ival); 
                        fprintf(yyout, "%d\n", $3.ival);
                        $$.val_type = INT_TYPE; 
                        $$.ival = $3.ival; 
                      }
                      else if ($3.val_type == FLOAT_TYPE) {   /* Assign a Float to the ID */
                        printf("[%s] %s = %g\n", type_to_str($1.id_val.val_type), $1.lexema, $3.fval); 
                        fprintf(yyout, "%g\n", $3.fval);
                        $$.val_type = FLOAT_TYPE;
                        $$.fval = $3.fval;
                      }
                      else if ($3.val_type == BOOL_TYPE) {    /* Assign a Boolean to the ID */
                        printf("[%s] %s = %s\n", type_to_str($1.id_val.val_type), $1.lexema, ($3.bval == 1) ? "true" : "false");
                        fprintf(yyout, "%d\n", $3.bval);
                        $$.val_type = BOOL_TYPE; $$.bval = $3.bval;
                      }
                      else if ($3.val_type == STRING_TYPE) {  /* Assign a String to the ID */
                        printf("[%s] %s = %s\n", type_to_str($1.id_val.val_type), $1.lexema, $3.sval); 
                        fprintf(yyout, "%s\n", $3.sval);
                        $$.val_type = STRING_TYPE; $$.sval = $3.sval;
                      }
                    }
  | expr  {
            if ($$.val_type == INT_TYPE) fprintf(yyout, "[Integer] %d\n", $1.ival);
            else if ($$.val_type == FLOAT_TYPE) fprintf(yyout, "[Float] %g\n", $1.fval);
            else if ($$.val_type == BOOL_TYPE) fprintf(yyout, "[Bool] %s\n", ($1.bval == 1) ? "true" : "false");
            else if ($$.val_type == STRING_TYPE) fprintf(yyout, "[String] %s\n", $1.sval);
          }
;

expr:
    LEN OP mult_expr CP { /* Can only use LEN() with a string */
                          if ($3.val_type == STRING_TYPE) {  $$.val_type = INT_TYPE; $$.ival = strlen($3.sval); }
                          else yyerror("Length (LEN()) cannot be applied to type '%s'. Only type 'String'", type_to_str($2.val_type));
                        }
  | SUB mult_expr       { /* Can only use Unary Minus Operator (-) with a number */
                          if ($2.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = -$2.ival; }
                          else if ($2.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = -$2.fval; }
                          else yyerror("Unary Minus Operator (-) cannot be applied to type '%s'. Only type 'Integer' and 'Float'", type_to_str($2.val_type));
                        }
  | ADD mult_expr       { /* Can only use Unary Plus Operator (+) with a number */
                          if ($2.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = +$2.ival; }
                          else if ($2.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = +$2.fval; }
                          else yyerror("Unary Plus Operator (+) cannot be applied to type '%s'. Only type 'Integer' and 'Float'", type_to_str($2.val_type));
                        }
  | expr ADD mult_expr  { /* If any one of the operands is a string, concatenate */
                          if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) {
                            char str[25];
                            cast_vals_to_flt(&$1, &$3);
                            $$.val_type = STRING_TYPE;
                            if ($1.val_type == STRING_TYPE) { /* If 1st operand is a string, then 2nd is any other type */
                              if ($3.val_type == STRING_TYPE) $$.sval = strcat($1.sval, $3.sval); /* If both operands are a string, concatenate them */
                              else if ($3.val_type == BOOL_TYPE) $$.sval = strcat($1.sval, ($3.bval == 1) ? "true" : "false"); /* Can concatenate booleans */
                              else {  /* If it's not a boolean, concatenate a number */
                                sprintf(str, "%g", $3.fval);
                                $$.sval = strcat($1.sval, str); 
                              }
                            }
                            else {  /* If 2nd operand is a string, then 1st is any other type */
                              if ($1.val_type == BOOL_TYPE) $$.sval = strcat(($1.bval == 1) ? "true" : "false", $3.sval); /* Can concatenate booleans */
                              else {  /* If it's not a boolean, concatenate a number */
                                sprintf(str, "%g", $1.fval);
                                $$.sval = strcat(str, $3.sval);
                              }
                            }
                          }
                          if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) yyerror("Addition (+) operator cannot be applied to type 'Boolean'");
                          if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { 
                            cast_vals_to_flt(&$1, &$3); 
                            $$.val_type = FLOAT_TYPE; 
                            $$.fval = $1.fval + $3.fval;
                          } else { 
                            $$.val_type = INT_TYPE; 
                            $$.ival = $1.ival + $3.ival; 
                          }
                        }
  | expr SUB mult_expr  { 
                          if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) yyerror("Subtraction (-) operator cannot be applied to type 'Boolean'");
                          else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) yyerror("Subtraction (-) operator cannot be applied to type 'String'");
                          else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { 
                            cast_vals_to_flt(&$1, &$3); 
                            $$.val_type = FLOAT_TYPE; 
                            $$.fval = $1.fval - $3.fval;
                          } else { 
                            $$.val_type = INT_TYPE; 
                            $$.ival = $1.ival - $3.ival; 
                          }
                        }
  | mult_expr
;


mult_expr:
    mult_expr MUL exp_expr    { 
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) yyerror("Multiplication (*) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) yyerror("Multiplication (*) operator cannot be applied to type 'String'");
                                else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { 
                                  cast_vals_to_flt(&$1, &$3); 
                                  $$.val_type = FLOAT_TYPE; 
                                  $$.fval = $1.fval * $3.fval;
                                } else { 
                                  $$.val_type = INT_TYPE; 
                                  $$.ival = $1.ival * $3.ival; 
                                }
                              }
  | mult_expr DIV exp_expr    {  
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) yyerror("Division (/) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) yyerror("Division (/) operator cannot be applied to type 'String'");
                                cast_vals_to_flt(&$1, &$3); 
                                if ($3.fval < 0.000001 && $3.fval > -0.000001) yyerror("Division by zero");
                                else { 
                                  $$.val_type = FLOAT_TYPE; 
                                  $$.fval = $1.fval / $3.fval;}
                              }
  | mult_expr MOD exp_expr    { 
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) yyerror("Modulo (%) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) yyerror("Modulo (%) operator cannot be applied to type 'String'");
                                if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { 
                                  if (($3.val_type == FLOAT_TYPE && ($3.fval < 0.000001 && $3.fval > -0.000001))  || ($3.val_type == INT_TYPE && $3.ival == 0)) yyerror("Modulo by zero");
                                  else { 
                                    cast_vals_to_flt(&$1, &$3); 
                                    $$.val_type = FLOAT_TYPE; 
                                    $$.fval = fmod($1.fval,$3.fval); 
                                  }
                                } else { 
                                  $$.val_type = INT_TYPE; 
                                  $$.ival = $1.ival % $3.ival; 
                                }
                              }
  | exp_expr
;

exp_expr:
    trig_expr POW exp_expr  { 
                              if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { 
                                cast_vals_to_flt(&$1, &$3); $$.val_type = FLOAT_TYPE; $$.fval = pow($1.fval,$3.fval);
                              } else { $$.val_type = INT_TYPE; $$.ival = pow($1.ival,$3.ival); }
                            }
  | trig_expr
;

trig_expr:
    SIN term_expr     { 
                          cast_vals_to_flt(&$2, NULL);
                          $$.val_type = FLOAT_TYPE; 
                          if(sin($2.fval) < 0.000001 && sin($2.fval) > -0.000001) $$.fval = 0;
                          else $$.fval = sin($2.fval);
                        }
  | COS term_expr     { 
                          cast_vals_to_flt(&$2, NULL); 
                          $$.val_type = FLOAT_TYPE; 
                          if(cos($2.fval) < 0.000001 && cos($2.fval) > -0.000001) $$.fval = 0;
                          else $$.fval = cos($2.fval);
                        }
  | TAN term_expr     { 
                          cast_vals_to_flt(&$2, NULL);
                          if(cos($2.fval) < 0.000001) yyerror("Indefinition error");
                          else { 
                                  $$.val_type = FLOAT_TYPE;
                                  $$.fval = sin($2.fval)/cos($2.fval);
                          }
                        }
  | term_expr
;

term_expr:
    INT         { $$.val_type = INT_TYPE; $$.ival = $1; }
  | FLOAT       { $$.val_type = FLOAT_TYPE; $$.fval = $1; }
  | BOOL        { $$.val_type = BOOL_TYPE; $$.bval = $1; }      
  | STRING      { $$.val_type = STRING_TYPE; $$.sval = $1; }
  | PI          { $$.val_type = FLOAT_TYPE; $$.fval = PI_CONST; }
  | E           { $$.val_type = FLOAT_TYPE; $$.fval = E_CONST; }
  | OP arit_expr CP   { 
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
      bool_orr ORR bool_and   { $$.bval = $1.bval || $3.bval; }
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
    | bool_expr     { $$.val_type = $1.val_type; $$.bval = $1.bval;}
    | OP bool_expr CP     { $$.val_type = $2.val_type; $$.bval = $2.bval;}
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
  | OP str_expr CP          { $$.val_type = $2.val_type; $$.sval = $2.sval;}
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