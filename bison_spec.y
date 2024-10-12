%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdbool.h>
  #include <unistd.h>
  #include <math.h>
  #include "dades.h"
  #include "funcions.h"
  

  int yydebug = 1;
  extern FILE *yyout;
  extern int yylineno;
  #define YYERROR_VERBOSE 1

  const double PI_CONST = 3.141592653589793;
  const double E_CONST = 2.718281828459045;

  int yylex(void);
  void yyerror(const char *s);
  void cast_vals_to_flt(value_info *op1, value_info *op2);
  void custom_err_mssg(const char *s);

  char err_mssg[150];
%}
%define parse.error verbose
%locations

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

%type <expr_val> stmnt expr mult_expr exp_expr trig_expr func_expr term_expr

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
                        fprintf(yyout, "[%s] %s = %d\n", type_to_str($1.id_val.val_type), $1.lexema, $3.ival);
                        $$.val_type = INT_TYPE; $$.ival = $3.ival; 
                      }
                      else if ($3.val_type == FLOAT_TYPE) {   /* Assign a Float to the ID */
                        fprintf(yyout, "[%s] %s = %g\n", type_to_str($1.id_val.val_type), $1.lexema, $3.fval);
                        $$.val_type = FLOAT_TYPE; $$.fval = $3.fval;
                      }
                      else if ($3.val_type == BOOL_TYPE) {    /* Assign a Boolean to the ID */
                        fprintf(yyout, "[%s] %s = %s\n", type_to_str($1.id_val.val_type), $1.lexema, ($3.bval == 1) ? "true" : "false");
                        $$.val_type = BOOL_TYPE; $$.bval = $3.bval;
                      }
                      else if ($3.val_type == STRING_TYPE) {  /* Assign a String to the ID */
                        fprintf(yyout, "[%s] %s = %s\n", type_to_str($1.id_val.val_type), $1.lexema, $3.sval);
                        $$.val_type = STRING_TYPE; $$.sval = $3.sval;
                      }
                    }
  | expr  {
            if ($$.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = $1.ival; fprintf(yyout, "[Integer] %d\n", $1.ival); }
            else if ($$.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.ival = $1.fval; fprintf(yyout, "[Float] %g\n", $1.fval); }
            else if ($$.val_type == BOOL_TYPE) { $$.val_type = BOOL_TYPE; $$.bval = $1.bval; fprintf(yyout, "[Boolean] %s\n", ($1.bval == 1) ? "true" : "false"); }
            else if ($$.val_type == STRING_TYPE) { $$.val_type = STRING_TYPE; $$.sval = $1.sval; fprintf(yyout, "[String] %s\n", $1.sval); }
          }
;

expr:
    SUB mult_expr       { /* Can only use Unary Minus Operator (-) with a number */
                          if ($2.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = -$2.ival; }
                          else if ($2.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = -$2.fval; }
                          else { sprintf(err_mssg, "Unary Minus Operator (-) cannot be applied to type '%s'. Only type 'Integer' and 'Float'", type_to_str($2.val_type)); custom_err_mssg(err_mssg); }
                        }
  | ADD mult_expr       { /* Can only use Unary Plus Operator (+) with a number */
                          if ($2.val_type == INT_TYPE) { $$.val_type = INT_TYPE; $$.ival = +$2.ival; }
                          else if ($2.val_type == FLOAT_TYPE) { $$.val_type = FLOAT_TYPE; $$.fval = +$2.fval; }
                          else { sprintf(err_mssg, "Unary Plus Operator (+) cannot be applied to type '%s'. Only type 'Integer' and 'Float'", type_to_str($2.val_type)); custom_err_mssg(err_mssg); }
                        }
  | expr ADD mult_expr  { /* If any one of the operands is a string, concatenate */
                          if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) {
                            char str[255];
                            cast_vals_to_flt(&$1, &$3);
                            $$.val_type = STRING_TYPE;
                            if ($1.val_type == STRING_TYPE) { /* If 1st operand is a string, then 2nd is any other type */
                              if ($3.val_type == STRING_TYPE) $$.sval = strcat($1.sval, $3.sval); /* If both operands are a string, concatenate them */
                              else if ($3.val_type == BOOL_TYPE) $$.sval = strcat($1.sval, ($3.bval == 1) ? "true" : "false"); /* Can concatenate booleans */
                              else {  /* If it's not a boolean, concatenate a number */
                                sprintf(str, "%g", $3.fval); $$.sval = strcat($1.sval, str);
                              }
                            }
                            else {  /* If 2nd operand is a string, then 1st is any other type */
                              if ($1.val_type == BOOL_TYPE) { /* Can concatenate booleans */
                                strcpy(str, ($1.bval == 1) ? "true" : "false");
                                $$.sval = strcat(str, $3.sval);
                              } 
                              else {  /* If it's not a boolean, concatenate a number */
                                sprintf(str, "%g", $1.fval); $$.sval = strcat(str, $3.sval);
                              }
                            }
                          } /* If none one of the operands is a string, a boolean cannot use the addition operator */
                          else if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Addition (+) operator cannot be applied to type 'Boolean'");
                          else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { /* If some operand is a Float, do a Float addition */
                            cast_vals_to_flt(&$1, &$3); $$.val_type = FLOAT_TYPE; $$.fval = $1.fval + $3.fval;
                          } else { /* If both operands are integers, do an Integer addition */
                            $$.val_type = INT_TYPE; $$.ival = $1.ival + $3.ival; 
                          }
                        }
  | expr SUB mult_expr  { /* Booleans and Strings cannot use the subtraction operator */
                          if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Subtraction (-) operator cannot be applied to type 'Boolean'");
                          else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) custom_err_mssg("Subtraction (-) operator cannot be applied to type 'String'");
                          else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) {  /* If some operand is a Float, do a Float subtraction */
                            cast_vals_to_flt(&$1, &$3); $$.val_type = FLOAT_TYPE; $$.fval = $1.fval - $3.fval;
                          } else { /* If both operands are integers, do an Integer subtraction */
                            $$.val_type = INT_TYPE; $$.ival = $1.ival - $3.ival; 
                          }
                        }
  | expr HIG mult_expr  { /* Booleans and Strings cannot use the higher operator */
                          if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Higher (>) operator cannot be applied to type 'Boolean'");
                          else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) custom_err_mssg("Higher (>) operator cannot be applied to type 'String'");
                          cast_vals_to_flt(&$1, &$3); $$.val_type = BOOL_TYPE; $$.bval = $1.fval > $3.fval;
                        }
  | expr HEQ mult_expr  { /* Booleans and Strings cannot use the higher or equal operator */
                          if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Higher or equal (>=) operator cannot be applied to type 'Boolean'");
                          else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) custom_err_mssg("Higher or equal (>=) operator cannot be applied to type 'String'");
                          cast_vals_to_flt(&$1, &$3); $$.val_type = BOOL_TYPE; $$.bval = $1.fval >= $3.fval;
                        }
  | expr LOW mult_expr       { /* Booleans and Strings cannot use the lower operator */
                          if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Lower (<) operator cannot be applied to type 'Boolean'");
                          else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) custom_err_mssg("Lower (<) operator cannot be applied to type 'String'");
                          cast_vals_to_flt(&$1, &$3); $$.val_type = BOOL_TYPE; $$.bval = $1.fval < $3.fval;
                        }
  | expr LEQ mult_expr  { /* Booleans and Strings cannot use the lower or equal operator */
                          if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Lower or equal (<=) operator cannot be applied to type 'Boolean'");
                          else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) custom_err_mssg("Lower or equal (<=) operator cannot be applied to type 'String'");
                          cast_vals_to_flt(&$1, &$3); $$.val_type = BOOL_TYPE; $$.bval = $1.fval <= $3.fval;
                        }
  | expr EQU mult_expr  { /* Booleans and Strings cannot use the equal operator */
                          if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Equal (==) operator cannot be applied to type 'Boolean'");
                          else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) custom_err_mssg("Equal (==) operator cannot be applied to type 'String'");
                          cast_vals_to_flt(&$1, &$3); $$.val_type = BOOL_TYPE; $$.bval = $1.fval == $3.fval;
                        }
  | expr NEQ mult_expr  { /* Booleans and Strings cannot use the not equal operator */
                          if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Not equal (<>) operator cannot be applied to type 'Boolean'");
                          else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) custom_err_mssg("Not equal (<>) operator cannot be applied to type 'String'");
                          cast_vals_to_flt(&$1, &$3); $$.val_type = BOOL_TYPE; $$.bval = $1.fval != $3.fval;
                        }
  | mult_expr
;


mult_expr: 
    mult_expr MUL exp_expr    { /* Booleans and Strings cannot use the multiplication operator */
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Multiplication (*) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) custom_err_mssg("Multiplication (*) operator cannot be applied to type 'String'");
                                else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) {  /* If some operand is a Float, do a Float multiplication */
                                  cast_vals_to_flt(&$1, &$3); $$.val_type = FLOAT_TYPE; $$.fval = $1.fval * $3.fval;
                                } else { /* If both operands are integers, do an Integer multiplication */
                                  $$.val_type = INT_TYPE; $$.ival = $1.ival * $3.ival; 
                                }
                              }
  | mult_expr DIV exp_expr    { 
                                cast_vals_to_flt(&$1, &$3); /* floats are used for the operation in order to get a float result */
                                /* Booleans and Strings cannot use the division operator */
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Division (/) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) custom_err_mssg("Division (/) operator cannot be applied to type 'String'");
                                else if ($3.fval < 0.000001 && $3.fval > -0.000001) custom_err_mssg("Division by zero"); /* If the divider is 0, error*/
                                else { /* If the divider is not 0, divide*/
                                  $$.val_type = FLOAT_TYPE; $$.fval = $1.fval / $3.fval;
                                }
                              }
  | mult_expr MOD exp_expr    { 
                                cast_vals_to_flt(&$1, &$3); /* floats are used to look for a divider == 0 */
                                /* Booleans and Strings cannot use the modulo operator */
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Modulo (%%) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) custom_err_mssg("Modulo (%%) operator cannot be applied to type 'String'");
                                else if (($3.fval < 0.000001 && $3.fval > -0.000001)) custom_err_mssg("Modulo by zero");  /* If the divider is 0, error*/
                                else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { /* If some operand is a Float, do a Float modulo */
                                  $$.val_type = FLOAT_TYPE; $$.fval = fmod($1.fval,$3.fval); 
                                } else { /* If both operands are integers, do an Integer division */
                                  $$.val_type = INT_TYPE; $$.ival = $1.ival % $3.ival; 
                                }
                              }
  | mult_expr ORR exp_expr    { /* Only booleans can use the or operator */
                                if ($1.val_type != BOOL_TYPE || $3.val_type != BOOL_TYPE) custom_err_mssg("Or (or) operator can only be applied to type 'Boolean'");
                                else {
                                  $$.val_type = BOOL_TYPE; $$.bval = $1.bval || $3.bval;
                                }
                              }
  | exp_expr
;

exp_expr:
    trig_expr POW exp_expr  { /* Booleans and Strings cannot use the power operator */
                              if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) custom_err_mssg("Power (**) operator cannot be applied to type 'Boolean'");
                              else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) custom_err_mssg("Power (**) operator cannot be applied to type 'String'");
                              else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { /* If some operand is a Float, do a Float power */
                                cast_vals_to_flt(&$1, &$3); $$.val_type = FLOAT_TYPE; $$.fval = pow($1.fval,$3.fval);
                              } else { /* If both operands are integers, do an Integer power */
                                $$.val_type = INT_TYPE; $$.ival = pow($1.ival,$3.ival); }
                            }
  | exp_expr AND trig_expr  { /* Only booleans can use the or operator */
                              if ($1.val_type != BOOL_TYPE || $3.val_type != BOOL_TYPE) custom_err_mssg("And (and) operator can only be applied to type 'Boolean'");
                              else { 
                                $$.val_type = BOOL_TYPE; $$.bval = $1.bval && $3.bval; 
                              }
                            }
  | trig_expr
;

trig_expr:
    SIN term_expr     { /* Booleans and Strings cannot be used in trigonometric expressions */
                        if ($2.val_type == BOOL_TYPE) custom_err_mssg("sin() cannot take a type 'Boolean' as a parameter");
                        else if ($2.val_type == STRING_TYPE) custom_err_mssg("sin() cannot take a type 'String' as a parameter");
                        else {
                          cast_vals_to_flt(&$2, NULL); $$.val_type = FLOAT_TYPE; /* Cast the values to float for easier validations */
                          if(sin($2.fval) < 0.000001 && sin($2.fval) > -0.000001) $$.fval = 0;  /* Values really close to 0 get treated as 0 */
                          else $$.fval = sin($2.fval);  /* calculate sin(x) */
                        }
                      }
  | COS term_expr     { 
                        /* Booleans and Strings cannot be used in trigonometric expressions */
                        if ($2.val_type == BOOL_TYPE) custom_err_mssg("cos() cannot take a type 'Boolean' as a parameter");
                        else if ($2.val_type == STRING_TYPE) custom_err_mssg("cos() cannot take a type 'String' as a parameter");
                        else {
                          cast_vals_to_flt(&$2, NULL); $$.val_type = FLOAT_TYPE; /* Cast the values to float for easier validations */
                          if(cos($2.fval) < 0.000001 && cos($2.fval) > -0.000001) $$.fval = 0;  /* Values really close to 0 get treated as 0 */
                          else $$.fval = cos($2.fval);  /* calculate cos(x) */
                        }
                      }
  | TAN term_expr     { 
                        /* Booleans and Strings cannot be used in trigonometric expressions */
                        if ($2.val_type == BOOL_TYPE) custom_err_mssg("tan() cannot take a type 'Boolean' as a parameter");
                        else if ($2.val_type == STRING_TYPE) custom_err_mssg("tan() cannot take a type 'String' as a parameter");
                        else {
                          cast_vals_to_flt(&$2, NULL);  /* Cast the values to float for easier validations */
                          if(cos($2.fval) < 0.000001) custom_err_mssg("Indefinition error");  /* tan(x) == sin(x)/cos(x) so if cos(x) == 0, we would be dividing by 0 */
                          else { 
                                  $$.val_type = FLOAT_TYPE; $$.fval = sin($2.fval)/cos($2.fval);  /* calculate tan(x) */
                          }
                        }
                      }
  | NOT term_expr     { /* Only booleans can use the or operator */
                        if ($2.val_type != BOOL_TYPE) custom_err_mssg("Not (not) operator can only be applied to type 'Boolean'");
                        else { 
                          $$.val_type = BOOL_TYPE;
                          $$.bval = !$2.bval; 
                        }
                      }
  | func_expr
;

func_expr:
    LEN OP func_expr CP { /* Can only use LEN() with a string */
                          if ($3.val_type == STRING_TYPE) {  $$.val_type = INT_TYPE; $$.ival = strlen($3.sval); }
                          else { sprintf(err_mssg, "LEN(String str) 1st parameter expects type 'String' but it got type '%s'", type_to_str($3.val_type)); custom_err_mssg(err_mssg); }
                        }
  | SUBSTR OP func_expr func_expr func_expr CP  { /* Can only use SUBSTR() with a string */
                                                  if ($3.val_type != STRING_TYPE) { sprintf(err_mssg, "SUBSTR(String str, Int start, Int length) 1st parameter expects type 'String' but it got type '%s'", type_to_str($3.val_type)); custom_err_mssg(err_mssg); }
                                                  else if ($4.val_type != INT_TYPE) { sprintf(err_mssg, "SUBSTR(String str, Int start, Int length) 2nd parameter expects type 'Integer' but it got type '%s'", type_to_str($4.val_type)); custom_err_mssg(err_mssg); }
                                                  else if ($5.val_type != INT_TYPE) { sprintf(err_mssg, "SUBSTR(String str, Int start, Int length) 3rd parameter expects type 'Integer' but it got type '%s'", type_to_str($5.val_type)); custom_err_mssg(err_mssg); }
                                                  else {
                                                    char *str = (char *)malloc($5.ival + 1); /* Ensure enough memory for the final substring */
                                                    memcpy(str, $3.sval+$4.ival, $5.ival); 
                                                    str[$5.ival] = '\0'; $$.val_type = STRING_TYPE; $$.sval = str;
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
  | OP expr CP  { 
                  $$.val_type = $2.val_type;
                  if ($2.val_type == INT_TYPE) $$.ival = $2.ival;
                  else if ($2.val_type == FLOAT_TYPE) $$.fval = $2.fval;
                  else if ($2.val_type == BOOL_TYPE) $$.bval = $2.bval;
                  else $$.sval = $2.sval;
                }
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

void custom_err_mssg(const char *s) {
  fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

int yywrap() {
  return 1;
}