%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdbool.h>
  #include <unistd.h>
  #include <math.h>
  #include "dades.h"
  #include "funcions.h"
  #include "symtab.h"
  

  int yydebug = 1;
  FILE* error_log;
  extern FILE* out3ac;
  extern FILE *yyout;
  extern int yylineno;
  extern char* input;
  #define YYERROR_VERBOSE 1

  const double PI_CONST = 3.141592653589793;
  const double E_CONST = 2.718281828459045;

  int yylex(void);
  void yyerror(const char *s);
  int contains(char *vars[], int size, const char *value);
  void cast_vals_to_flt(value_info *op1, value_info *op2, bool store3ac);
  char* switch_bases(value_info *val, base base);
  void explicit_cast_value(value_info *value, const char *cast_type);
  void custom_err_mssg(const char *s);
  void c3a(const char *s);
  void buildTable(char *vars[], int var_index);

  char err_mssg[256];
  char c3a_mssg[256];
  bool err = false;
  char *to_str;
  char *vars[256];
  int var_index = 0;
  int c3aLineNo = 0;
  int c3aOpCount = 1;
  int c3aLines = 0;
  int previousLines;

  int loopLine[8];
  char loopTemp[8][16];
  char loopCondTemp[8][16];
  bool isConditionalLoop[8] = {[0 ... 7] = false};
  char loopBuffer[8][512][256];
  int loopBufferIndex[8] = {[0 ... 7] = 0};
  bool writtingBufferToFile = false;

  int loopIndex = -1;
%}
%define parse.error verbose
%locations

%code requires {
  #include "dades.h"
  #include "funcions.h"
  #include "symtab.h"
}

%union{
    id id;
    int ival;
    float fval;
    char* sval;
    value_info expr_val;
    void *sense_valor;
}

%token <id> ID
%token <ival> INT BOOL
%token <fval> FLOAT PI E SIN COS TAN
%token <sval> STRING BASE CAST
%token <sense_valor> COMM ASSIGN ENDLINE
                      ADD SUB MUL DIV MOD POW 
                      HIG HEQ LOW LEQ EQU NEQ 
                      NOT AND ORR
                      LEN SUBSTR
                      OP CP OB CB
                      SHVAR
                      REP WHL UNTL DO DONE

%type <expr_val> stmnt expr expr1 expr2 expr3 expr4 expr_term

%start calculator

%%

calculator:
    stmnt_list  { c3a("HALT"); }
;

stmnt_list:
        stmnt ENDLINE stmnt_list
    |   loop ENDLINE stmnt_list
    |   loop stmnt_list
    |   ENDLINE stmnt_list
    |   /* empty */     { /* Allow empty input */ }
;

loop:
    REP stmnt DO    {
                        if ($2.val_type == INT_TYPE) {
                            if ($2.ival > 0) {
                                loopIndex++;
                                sprintf(loopTemp[loopIndex], "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %d", loopTemp[loopIndex], 0);
                                c3a(c3a_mssg);
                                loopLine[loopIndex] = c3aLineNo + 1;
                                sprintf(loopCondTemp[loopIndex], "%s", $2.temp);
                            } else {
                                sprintf(err_mssg, "Loop has to be repeated at least 1 time, not lower");
                                custom_err_mssg(err_mssg);
                            }
                        } else {
                            sprintf(err_mssg, "Structure for a repeat loop is \"repeat <arithmetic_integer_expression> do <statement_list> done\"");
                            custom_err_mssg(err_mssg);
                        }
                        err = false;
                    }
    | WHL stmnt DO  {
                        if ($2.val_type == BOOL_TYPE) {
                            loopIndex++;
                            sprintf(loopTemp[loopIndex], "%s", $2.temp);
                            loopLine[loopIndex] = c3aLineNo - previousLines + 1;
                            isConditionalLoop[loopIndex] = true;
                            loopBufferIndex[loopIndex]++;
                        } else {
                            sprintf(err_mssg, "Structure for a while loop is \"while <boolean_expression> do <statement_list> done\"");
                            free(to_str);
                            custom_err_mssg(err_mssg);
                        }
                        err = false;
                    }
    | DONE  {   
                if (loopIndex >= 0) {
                    if (!isConditionalLoop[loopIndex]) {
                        int i;
                        for (i = 0; i<loopBufferIndex[loopIndex]; i++) {
                            if (loopIndex > 0) {
                                char temp[256];
                                sprintf(temp, "%s", loopBuffer[loopIndex][loopBufferIndex[loopIndex]]);
                                sprintf(loopBuffer[loopIndex-1][loopBufferIndex[loopIndex-1]], "%s", temp);
                            } else {
                                writtingBufferToFile = true;
                                sprintf(c3a_mssg, "%s", loopBuffer[0][i]);
                                c3a(c3a_mssg);
                            }
                        }
                        sprintf(c3a_mssg, "%s := %s ADDI %d", loopTemp[loopIndex], loopTemp[loopIndex], 1);
                        c3a(c3a_mssg);
                        sprintf(c3a_mssg, "IF %s LTI %s GOTO %d", loopTemp[loopIndex], loopCondTemp[loopIndex], loopLine[loopIndex]);
                        c3a(c3a_mssg);
                        writtingBufferToFile = false;
                    } else {
                        sprintf(loopBuffer[loopIndex][0], "IF %s NE true GOTO %d", loopTemp[loopIndex], c3aLineNo + loopBufferIndex[loopIndex] + 2);
                        int i;
                        for (i = 0; i<loopBufferIndex[loopIndex]; i++) {
                            if (loopIndex > 0) {
                                char temp[256];
                                sprintf(temp, "%s", loopBuffer[loopIndex][loopBufferIndex[loopIndex]]);
                                sprintf(loopBuffer[loopIndex-1][loopBufferIndex[loopIndex-1]], "%s", temp);
                            } else {
                                writtingBufferToFile = true;
                                sprintf(c3a_mssg, "%s", loopBuffer[0][i]);
                                c3a(c3a_mssg);
                            }
                        }
                        sprintf(c3a_mssg, "GOTO %d", loopLine[loopIndex]);
                        c3a(c3a_mssg);
                        writtingBufferToFile = false;
                    }
                    loopIndex--;
                } else {
                    sprintf(err_mssg, "Cannot use the word 'done' without a previous loop declaration\"");
                    free(to_str);
                    custom_err_mssg(err_mssg);
                }
                err = false;
                
            }
;

stmnt:
    ID ASSIGN expr  {
                        if(!err) {
                            $1.id_val.val_type = $3.val_type;   /* Match the ID type to the assignation's */
                            to_str = type_to_str($1.id_val.val_type);
                            if ($3.val_type == INT_TYPE) {      /* Assign an Integer to the ID */
                                fprintf(yyout, "[%s] %s = %d\n", to_str, $1.name, $3.ival);
                                $1.id_val.ival = $3.ival;
                                $$.ival = $3.ival;
                            }
                            else if ($3.val_type == FLOAT_TYPE) {   /* Assign a Float to the ID */
                                fprintf(yyout, "[%s] %s = %g\n", to_str, $1.name, $3.fval);
                                $1.id_val.fval = $3.fval;
                                $$.fval = $3.fval;
                            }
                            else if ($3.val_type == BOOL_TYPE) {    /* Assign a Boolean to the ID */
                                fprintf(yyout, "[%s] %s = %s\n", to_str, $1.name, ($3.bval == 1) ? "true" : "false");
                                $1.id_val.bval = $3.bval;
                                $$.bval = $3.bval;
                            }
                            else if ($3.val_type == STRING_TYPE) {  /* Assign a String to the ID */
                                fprintf(yyout, "[%s] %s = %s\n", to_str, $1.name, $3.sval);
                                $1.id_val.sval = $3.sval;
                                $$.sval = $3.sval;
                            }
                            $$.val_type = $3.val_type;
                            sprintf($$.temp, "%s", $1.name);
                            sprintf(c3a_mssg, "%s := %s", $1.name, $3.temp);
                            c3a(c3a_mssg);
                            sym_enter($1.name, &$1);
                            vars[var_index] = $1.name;
                            var_index++;
                            free(to_str);
                        } 
                        err = false;
                        previousLines = c3aLines;
                        c3aLines = 0;
                    }
    | ID OB expr CB ASSIGN expr {
                                    if(!err) {
                                        if ($3.val_type == FLOAT_TYPE && (($3.fval - floor($3.fval) < 0.000001) && ($3.fval - floor($3.fval) > -0.000001))) {
                                            $3.ival = floor($3.fval);
                                            $3.val_type = INT_TYPE;
                                            sprintf(c3a_mssg, "$t%03d := F2I %s", c3aOpCount++, $3.temp);
                                            sprintf($3.temp, "$t%03d", c3aOpCount);
                                            c3a(c3a_mssg);
                                        }
                                        if($3.val_type == INT_TYPE) {
                                            char* name = $1.name;
                                            char arrayName[128];
                                            sprintf(arrayName, "%s[0]", name);
                                            int result = contains(vars, var_index+1, arrayName);
                                            if (result == 0) { /* If there is no array with this name, create placeholders for all of the elements of the array */
                                                int i;
                                                for (i = 0; i < $3.ival+1; i++) {
                                                    char* newLmnName = malloc(128);
                                                    sprintf(newLmnName, "%s[%d]", name, i);
                                                    id idPlaceHolder = {newLmnName, {UNKNOWN_TYPE}, NO_BASE};
                                                    sym_enter(newLmnName, &idPlaceHolder);
                                                    vars[var_index] = newLmnName;
                                                    var_index++;
                                                }
                                            }
                                            sprintf(arrayName, "%s[%d]", name, $3.ival);
                                            int isWithinArrayLength = contains(vars, var_index+1, arrayName);
                                            if (isWithinArrayLength == 0) { /* If an array with the same name has already been initialized but we are exceeding its max elements, notify */
                                                sprintf(err_mssg, "Array '%s[]' cannot be resized to accept element '%s[%d]'", name, name, $3.ival);
                                                custom_err_mssg(err_mssg);
                                            }
                                            else { /* If we are trying to modify an existing array's element (within its first initialized length), proceed */
                                                sprintf($1.name, "%s[%d]", $1.name, $3.ival);
                                                $1.id_val.val_type = $6.val_type;   /* Match the ID type to the assignation's */
                                                to_str = type_to_str($1.id_val.val_type);
                                                if ($6.val_type == INT_TYPE) {      /* Assign an Integer to the ID */
                                                    fprintf(yyout, "[%s] %s = %d\n", to_str, $1.name, $6.ival);
                                                    $1.id_val.ival = $6.ival;
                                                    $$.ival = $6.ival;
                                                }
                                                else if ($6.val_type == FLOAT_TYPE) {   /* Assign a Float to the ID */
                                                    fprintf(yyout, "[%s] %s = %g\n", to_str, $1.name, $6.fval);
                                                    $1.id_val.fval = $6.fval;
                                                    $$.fval = $6.fval;
                                                }
                                                else if ($6.val_type == BOOL_TYPE) {    /* Assign a Boolean to the ID */
                                                    fprintf(yyout, "[%s] %s = %s\n", to_str, $1.name, ($6.bval == 1) ? "true" : "false");
                                                    $1.id_val.bval = $6.bval;
                                                    $$.bval = $6.bval;
                                                }
                                                else if ($6.val_type == STRING_TYPE) {  /* Assign a String to the ID */
                                                    fprintf(yyout, "[%s] %s = %s\n", to_str, $1.name, $6.sval);
                                                    $1.id_val.sval = $6.sval;
                                                    $$.sval = $6.sval;
                                                }
                                                sprintf($$.temp, "%s", $1.name);
                                                sprintf(c3a_mssg, "%s := %s", $1.name, $6.temp);
                                                c3a(c3a_mssg);
                                                sym_enter($1.name, &$1); /* Update the desired element in the array */
                                            }
                                        }
                                        else { /* Only access an array if indexing with integers */
                                            to_str = type_to_str($3.val_type);
                                            sprintf(err_mssg, "Arrays can only be accessed using 'Integer', not '%s'", to_str);
                                            free(to_str);
                                            custom_err_mssg(err_mssg);
                                        }
                                    }
                                    err = false;
                                    previousLines = c3aLines;
                                    c3aLines = 0; 
                                }
    | ID ASSIGN expr BASE   {   
                                if(!err) {
                                    if ($3.val_type != INT_TYPE) {
                                        to_str = type_to_str($3.val_type);
                                        sprintf(err_mssg, "Base conversion (b10 to %s) cannot be applied to type '%s'. Only type 'Integer'", $4, to_str);
                                        free(to_str);
                                        custom_err_mssg(err_mssg);
                                    }
                                    else {
                                        $1.id_val.val_type = $3.val_type;   /* Match the ID type to the assignation's */
                                        to_str = type_to_str($1.id_val.val_type);
                                        if (strcmp($4, "b2") == 0) $1.base = BIN_BASE;
                                        else if (strcmp($4, "b8") == 0) $1.base = OCT_BASE;
                                        else if (strcmp($4, "b10") == 0) $1.base = DEC_BASE;
                                        else if (strcmp($4, "b16") == 0) $1.base = HEX_BASE;
                                        fprintf(yyout, "[%s] %s = %s\n", to_str, $1.name, switch_bases(&$3, $1.base));
                                        sprintf(c3a_mssg, "%s := %s", $1.name, $3.temp);
                                        c3a(c3a_mssg);
                                        $1.id_val.ival = $3.ival;
                                        $$.ival = $3.ival;
                                        sprintf($$.temp, "%s", $1.name);
                                        sym_enter($1.name, &$1);
                                        vars[var_index] = $1.name;
                                        var_index++;
                                        free(to_str);
                                    }
                                } 
                                err = false;
                                previousLines = c3aLines;
                                c3aLines = 0;
                            }
    | ID OB expr CB ASSIGN expr BASE    {
                                            if(!err) {
                                                if($3.val_type == INT_TYPE) {
                                                    char* name = $1.name;
                                                    char arrayName[128];
                                                    sprintf(arrayName, "%s[0]", name);
                                                    int result = contains(vars, var_index+1, arrayName);
                                                    if (result == 0) { /* If there is no array with this name, create placeholders for all of the elements of the array */
                                                        int i;
                                                        for (i = 0; i < $3.ival+1; i++) {
                                                            char* newLmnName = malloc(128);
                                                            sprintf(newLmnName, "%s[%d]", name, i);
                                                            id idPlaceHolder = {newLmnName, {UNKNOWN_TYPE}, NO_BASE};
                                                            sym_enter(newLmnName, &idPlaceHolder);
                                                            vars[var_index] = newLmnName;
                                                            var_index++;
                                                        }
                                                    }
                                                    sprintf(arrayName, "%s[%d]", name, $3.ival);
                                                    int isWithinArrayLength = contains(vars, var_index+1, arrayName);
                                                    if (isWithinArrayLength == 0) { /* If an array with the same name has already been initialized but we are exceeding its max elements, notify */
                                                        sprintf(err_mssg, "Array '%s[]' cannot be resized to accept element '%s[%d]'", name, name, $3.ival);
                                                        custom_err_mssg(err_mssg);
                                                    }
                                                    else { /* If we are trying to modify an existing array's element (within its first initialized length), proceed */
                                                        sprintf($1.name, "%s[%d]", $1.name, $3.ival);
                                                        if ($6.val_type != INT_TYPE) {
                                                            to_str = type_to_str($6.val_type);
                                                            sprintf(err_mssg, "Base conversion (b10 to %s) cannot be applied to type '%s'. Only type 'Integer'", $7, to_str);
                                                            free(to_str);
                                                            custom_err_mssg(err_mssg);
                                                        }
                                                        else {
                                                            $1.id_val.val_type = $6.val_type;   /* Match the ID type to the assignation's */
                                                            to_str = type_to_str($1.id_val.val_type);
                                                            if (strcmp($7, "b2") == 0) $1.base = BIN_BASE;
                                                            else if (strcmp($7, "b8") == 0) $1.base = OCT_BASE;
                                                            else if (strcmp($7, "b10") == 0) $1.base = DEC_BASE;
                                                            else if (strcmp($7, "b16") == 0) $1.base = HEX_BASE;
                                                            fprintf(yyout, "[%s] %s = %s\n", to_str, $1.name, switch_bases(&$6, $1.base));
                                                            sprintf(c3a_mssg, "%s := %s", $1.name, $6.temp);
                                                            c3a(c3a_mssg);
                                                            $1.id_val.ival = $6.ival;
                                                            $$.ival = $6.ival;
                                                            sprintf($$.temp, "%s", $1.name);
                                                            sym_enter($1.name, &$1);
                                                            free(to_str);
                                                        }
                                                    }
                                                }
                                                else { /* Only access an array if indexing with integers */
                                                    to_str = type_to_str($3.val_type);
                                                    sprintf(err_mssg, "Arrays can only be accessed using 'Integer', not '%s'", to_str);
                                                    free(to_str);
                                                    custom_err_mssg(err_mssg);
                                                }
                                            }
                                            err = false;
                                            previousLines = c3aLines;
                                            c3aLines = 0; 
                                        }
    | expr      {
                    if(!err) {
                        if ($$.val_type == INT_TYPE) { 
                            $$.val_type = INT_TYPE; 
                            $$.ival = $1.ival; 
                            fprintf(yyout, "[Integer] %d\n", $1.ival);
                        }
                        else if ($$.val_type == FLOAT_TYPE) { 
                            $$.val_type = FLOAT_TYPE; 
                            $$.ival = $1.fval; 
                            fprintf(yyout, "[Float] %g\n", $1.fval);
                        }
                        else if ($$.val_type == BOOL_TYPE) { 
                            $$.val_type = BOOL_TYPE; 
                            $$.bval = $1.bval; 
                            fprintf(yyout, "[Boolean] %s\n", ($1.bval == 1) ? "true" : "false"); 
                        }
                        else if ($$.val_type == STRING_TYPE) { 
                            $$.val_type = STRING_TYPE; 
                            $$.sval = $1.sval; 
                            fprintf(yyout, "[String] %s\n", $1.sval); 
                        }
                        sprintf(c3a_mssg, "PARAM %s", $$.temp);
                        c3a(c3a_mssg);
                        c3a("CALL PUTI, 1");
                    } 
                    err = false;
                    previousLines = c3aLines;
                    c3aLines = 0;
                }
    | expr BASE {
                    if(!err) {
                        to_str = type_to_str($1.val_type);
                        if ($$.val_type != INT_TYPE) {
                            sprintf(err_mssg, "Base conversion (b10 to %s) cannot be applied to type '%s'. Only type 'Integer'", $2, to_str);
                            free(to_str);
                            custom_err_mssg(err_mssg);
                        }
                        else {
                            base base;
                            if (strcmp($2, "b2") == 0) base = BIN_BASE;
                            else if (strcmp($2, "b8") == 0) base = OCT_BASE;
                            else if (strcmp($2, "b10") == 0) base = DEC_BASE;
                            else if (strcmp($2, "b16") == 0) base = HEX_BASE;
                            $$.val_type = INT_TYPE; 
                            $$.ival = $1.ival;
                            fprintf(yyout, "[Integer] %s\n", switch_bases(&$1, base));
                            sprintf(c3a_mssg, "PARAM %s", $$.temp);
                            c3a(c3a_mssg);
                            c3a("CALL PUTI, 1");
                        }
                    } 
                    err = false;
                    previousLines = c3aLines;
                    c3aLines = 0;
                }
    | SHVAR { 
                buildTable(vars, var_index);
                previousLines = c3aLines;
                c3aLines = 0;
            }
;

expr:
    SUB expr1   { /* Can only use Unary Minus Operator (-) with a number */
                    if ($2.val_type == INT_TYPE) {
                        $$.val_type = INT_TYPE; 
                        $$.ival = -$2.ival;
                        sprintf($$.temp, "$t%03d", c3aOpCount++);
                        sprintf(c3a_mssg, "%s := CHSI %s", $$.temp, $2.temp);
                        c3a(c3a_mssg);
                    }
                    else if ($2.val_type == FLOAT_TYPE) {
                        $$.val_type = FLOAT_TYPE; 
                        $$.fval = -$2.fval;
                        sprintf($$.temp, "$t%03d", c3aOpCount++);
                        sprintf(c3a_mssg, "%s := CHSF %s", $$.temp, $2.temp);
                        c3a(c3a_mssg);
                    }
                    else {
                        to_str = type_to_str($2.val_type);
                        sprintf(err_mssg, "Unary Minus Operator (-) cannot be applied to type '%s'. Only type 'Integer' and 'Float'", to_str);
                        free(to_str);
                        custom_err_mssg(err_mssg); 
                    }
                }
    | ADD expr1 { /* Can only use Unary Plus Operator (+) with a number */
                    if ($2.val_type == INT_TYPE) { 
                        $$.val_type = INT_TYPE; 
                        $$.ival = abs($2.ival);
                        if ($$.ival > $2.ival) {
                            sprintf($$.temp, "$t%03d", c3aOpCount++);
                            sprintf(c3a_mssg, "%s := CHSI %s", $$.temp, $2.temp);
                            c3a(c3a_mssg);
                        } else sprintf($$.temp, "%s", $2.temp);
                    }
                    else if ($2.val_type == FLOAT_TYPE) { 
                        $$.val_type = FLOAT_TYPE; 
                        $$.fval = fabs($2.fval);
                        if ($$.ival > $2.fval) {
                            sprintf($$.temp, "$t%03d", c3aOpCount++);
                            sprintf(c3a_mssg, "%s := CHSF %s", $$.temp, $2.temp);
                            c3a(c3a_mssg);
                        } else sprintf($$.temp, "%s", $2.temp);
                    }
                    else { 
                        to_str = type_to_str($2.val_type);
                        sprintf(err_mssg, "Unary Plus Operator (+) cannot be applied to type '%s'. Only type 'Integer' and 'Float'", to_str); 
                        free(to_str);
                        custom_err_mssg(err_mssg); 
                    }
                }
    | expr ADD expr1    { /* If any one of the operands is a string, concatenate */
                            if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) {
                                char str1[255];
                                char* str;
                                cast_vals_to_flt(&$1, &$3, false);
                                $$.val_type = STRING_TYPE;
                                if ($1.val_type == STRING_TYPE) { /* If 1st operand is a string, then 2nd is any other type */
                                    if ($3.val_type == STRING_TYPE) {  /* If both operands are a string, concatenate them */
                                        str = malloc(strlen($1.sval) + strlen($3.sval) + 1);  /* allocate enough memory for 2 strings */
                                        strcpy(str, $1.sval);
                                        $$.sval = strcat(str, $3.sval);
                                    }
                                    else if ($3.val_type == BOOL_TYPE) {
                                        str = malloc(strlen($1.sval) + strlen("false") + 1);  /* allocate enough memory for a string and the word 'false' at most */
                                        strcpy(str, $1.sval);
                                        $$.sval = strcat(str, ($3.bval == 1) ? "true" : "false"); /* Can concatenate booleans */
                                    }
                                    else {  /* If it's not a boolean, concatenate a number */
                                        str = malloc(strlen($1.sval) + sizeof(char) * 32 + 1);  /* allocate enough memory for a string and a 32 bit number */
                                        strcpy(str, $1.sval);
                                        sprintf(str1, "%g", $3.fval);
                                        $$.sval = strcat(str, str1);
                                    }
                                }
                                else {  /* If 2nd operand is a string, then 1st is any other type */
                                    if ($1.val_type == BOOL_TYPE) { /* Can concatenate booleans */
                                        str = malloc(strlen($3.sval) + strlen("false") + 1);  /* allocate enough memory for a string and the word 'false' at most */
                                        strcpy(str, ($1.bval == 1) ? "true" : "false");
                                        $$.sval = strcat(str, $3.sval);
                                    } 
                                    else {  /* If it's not a boolean, concatenate a number */
                                        str = malloc(strlen($3.sval) + sizeof(char) * 32 + 1);  /* allocate enough memory for a string and a 32 bit number */
                                        sprintf(str, "%g", $1.fval); 
                                        $$.sval = strcat(str, $3.sval);
                                    }
                                }
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s CONCAT %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            } /* If none one of the operands is a string, a boolean cannot use the addition operator */
                            else if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                                custom_err_mssg("Addition (+) operator cannot be applied to type 'Boolean'");
                            else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { /* If some operand is a Float, do a Float addition */
                                cast_vals_to_flt(&$1, &$3, true);
                                $$.val_type = FLOAT_TYPE; 
                                $$.fval = $1.fval + $3.fval;
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s ADDF %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            } else { /* If both operands are integers, do an Integer addition */
                                $$.val_type = INT_TYPE; 
                                $$.ival = $1.ival + $3.ival;
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s ADDI %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            }
                        }
    | expr SUB expr1    { /* Booleans and Strings cannot use the subtraction operator */
                            if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                                custom_err_mssg("Subtraction (-) operator cannot be applied to type 'Boolean'");
                            else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) 
                                custom_err_mssg("Subtraction (-) operator cannot be applied to type 'String'");
                            else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) {  /* If some operand is a Float, do a Float subtraction */
                                cast_vals_to_flt(&$1, &$3, true); 
                                $$.val_type = FLOAT_TYPE; 
                                $$.fval = $1.fval - $3.fval;
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s SUBF %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            } else { /* If both operands are integers, do an Integer subtraction */
                                $$.val_type = INT_TYPE; 
                                $$.ival = $1.ival - $3.ival;
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s SUBI %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            }
                        }
    | expr1
;


expr1: 
    expr1 MUL expr2 { /* Booleans and Strings cannot use the multiplication operator */
                        if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                            custom_err_mssg("Multiplication (*) operator cannot be applied to type 'Boolean'");
                        else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) 
                            custom_err_mssg("Multiplication (*) operator cannot be applied to type 'String'");
                        else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) {  /* If some operand is a Float, do a Float multiplication */
                            cast_vals_to_flt(&$1, &$3, true); 
                            $$.val_type = FLOAT_TYPE; 
                            $$.fval = $1.fval * $3.fval;
                            sprintf($$.temp, "$t%03d", c3aOpCount++);
                            sprintf(c3a_mssg, "%s := %s MULF %s", $$.temp, $1.temp, $3.temp);
                            c3a(c3a_mssg);
                        } else { /* If both operands are integers, do an Integer multiplication */
                            $$.val_type = INT_TYPE; 
                            $$.ival = $1.ival * $3.ival;
                            sprintf($$.temp, "$t%03d", c3aOpCount++);
                            sprintf(c3a_mssg, "%s := %s MULI %s", $$.temp, $1.temp, $3.temp);
                            c3a(c3a_mssg);
                        }
                    }
    | expr1 DIV expr2   { 
                            cast_vals_to_flt(&$1, &$3, true); /* floats are used for the operation in order to get a float result */
                            /* Booleans and Strings cannot use the division operator */
                            if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                                custom_err_mssg("Division (/) operator cannot be applied to type 'Boolean'");
                            else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) 
                                custom_err_mssg("Division (/) operator cannot be applied to type 'String'");
                            else if ($3.ival == 0) {
                                custom_err_mssg("Division by zero"); /* If the divider is 0, error*/
                            } else { /* If the divider is not 0, divide*/
                                $$.val_type = FLOAT_TYPE; 
                                $$.fval = $1.fval / $3.fval;
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s DIVF %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            }
                        }
    | expr1 MOD expr2   { 
                            cast_vals_to_flt(&$1, &$3, true); /* floats are used to look for a divider == 0 */
                            /* Booleans and Strings cannot use the modulo operator */
                            if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                                custom_err_mssg("Modulo (%%) operator cannot be applied to type 'Boolean'");
                            else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) 
                                custom_err_mssg("Modulo (%%) operator cannot be applied to type 'String'");
                            else if (($3.fval < 0.000001 && $3.fval > -0.000001)) 
                                custom_err_mssg("Modulo by zero");  /* If the divider is 0, error*/
                            else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { /* If some operand is a Float, do a Float modulo */
                                $$.val_type = FLOAT_TYPE; 
                                $$.fval = fmod($1.fval,$3.fval);
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s MODF %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            } else { /* If both operands are integers, do an Integer division */
                                $$.val_type = INT_TYPE; 
                                $$.ival = $1.ival % $3.ival;
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s MODI %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            }
                        }
    | expr1 ORR expr2   { /* Only booleans can use the or operator */
                            if ($1.val_type != BOOL_TYPE || $3.val_type != BOOL_TYPE) 
                                custom_err_mssg("Or (or) operator can only be applied to type 'Boolean'");
                            else {
                                $$.val_type = BOOL_TYPE; 
                                $$.bval = $1.bval || $3.bval;
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s ORR %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            }
                        }
    | expr2
;

expr2:
    expr3 POW expr2 { /* Booleans and Strings cannot use the power operator */
                        if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                            custom_err_mssg("Power (**) operator cannot be applied to type 'Boolean'");
                        else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) 
                            custom_err_mssg("Power (**) operator cannot be applied to type 'String'");
                        else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) { /* If some operand is a Float, do a Float power */
                            cast_vals_to_flt(&$1, &$3, true);
                            $$.val_type = FLOAT_TYPE; 
                            $$.fval = pow($1.fval, $3.fval);
                            int flooredVal = floor($3.fval);
                            sprintf($$.temp, "$t%03d", c3aOpCount++);
                            sprintf(c3a_mssg, "%s := %g", $$.temp, $1.fval); /* Initialize value to multiply over itself */
                            c3a(c3a_mssg);
                            sprintf(loopTemp[loopIndex], "$t%03d", c3aOpCount++);
                            sprintf(c3a_mssg, "%s := %d", loopTemp[loopIndex], 1); /* Start from iteration 1 instead of 0 */
                            c3a(c3a_mssg);
                            loopLine[loopIndex] = c3aLineNo + 1;
                            sprintf(loopCondTemp[loopIndex], "%d", flooredVal);
                            sprintf(c3a_mssg, "%s := %s MULF %g", $$.temp, $$.temp, $1.fval); /* Multiply value over itslef */
                            c3a(c3a_mssg);
                            sprintf(c3a_mssg, "%s := %s ADDI %d", loopTemp[loopIndex], loopTemp[loopIndex], 1); /* Keep iterating */
                            c3a(c3a_mssg);
                            sprintf(c3a_mssg, "IF %s LTI %s GOTO %d", loopTemp[loopIndex], loopCondTemp[loopIndex], loopLine[loopIndex]);
                            c3a(c3a_mssg);
                            if ($3.val_type == FLOAT_TYPE) {
                                float floatingExp = $3.fval - flooredVal;
                                float floatingVal = exp(floatingExp * log($1.fval)); /* Calculate the floating power as a^b = e^(b * ln(a)) */
                                sprintf(c3a_mssg, "%s := %s MULF %g", $$.temp, $$.temp, floatingVal);
                                c3a(c3a_mssg);
                            }
                        } else { /* If both operands are integers, do an Integer power */
                            $$.val_type = INT_TYPE;
                            $$.ival = pow($1.ival, $3.ival);
                            sprintf($$.temp, "$t%03d", c3aOpCount++);
                            sprintf(c3a_mssg, "%s := %d", $$.temp, $1.ival); /* Initialize value to multiply over itself */
                            c3a(c3a_mssg);
                            sprintf(loopTemp[loopIndex], "$t%03d", c3aOpCount++);
                            sprintf(c3a_mssg, "%s := %d", loopTemp[loopIndex], 1); /* Start from iteration 1 instead of 0 */
                            c3a(c3a_mssg);
                            loopLine[loopIndex] = c3aLineNo + 1;
                            sprintf(loopCondTemp[loopIndex], "%d", $3.ival);
                            sprintf(c3a_mssg, "%s := %s MULI %d", $$.temp, $$.temp, $1.ival); /* Multiply value over itslef */
                            c3a(c3a_mssg);
                            sprintf(c3a_mssg, "%s := %s ADDI %d", loopTemp[loopIndex], loopTemp[loopIndex], 1); /* Keep iterating */
                            c3a(c3a_mssg);
                            sprintf(c3a_mssg, "IF %s LTI %s GOTO %d", loopTemp[loopIndex], loopCondTemp[loopIndex], loopLine[loopIndex]);
                            c3a(c3a_mssg);                        
                        }
                    }
    | expr2 AND expr3   { /* Only booleans can use the or operator */
                            if ($1.val_type != BOOL_TYPE || $3.val_type != BOOL_TYPE) 
                                custom_err_mssg("And (and) operator can only be applied to type 'Boolean'");
                            else { 
                                $$.val_type = BOOL_TYPE; 
                                $$.bval = $1.bval && $3.bval;
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s AND %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            }
                        }
    | expr3
;

expr3:
    SIN expr4   { /* Booleans and Strings cannot be used in trigonometric expressions */
                    if ($2.val_type == BOOL_TYPE) 
                        custom_err_mssg("sin() cannot take a type 'Boolean' as a parameter");
                    else if ($2.val_type == STRING_TYPE) 
                        custom_err_mssg("sin() cannot take a type 'String' as a parameter");
                    else {
                        cast_vals_to_flt(&$2, NULL, true); /* Cast the values to float for easier validations */
                        $$.val_type = FLOAT_TYPE; 
                        if(sin($2.fval) < 0.000001 && sin($2.fval) > -0.000001) $$.fval = 0;  /* Values really close to 0 get treated as 0 */
                        else $$.fval = sin($2.fval);  /* calculate sin(x) */
                        sprintf($$.temp, "$t%03d", c3aOpCount++);
                        sprintf(c3a_mssg, "%s := SIN %s", $$.temp, $2.temp);
                        c3a(c3a_mssg);
                    }
                }
    | COS expr4 { 
                    /* Booleans and Strings cannot be used in trigonometric expressions */
                    if ($2.val_type == BOOL_TYPE) 
                        custom_err_mssg("cos() cannot take a type 'Boolean' as a parameter");
                    else if ($2.val_type == STRING_TYPE) 
                        custom_err_mssg("cos() cannot take a type 'String' as a parameter");
                    else {
                        cast_vals_to_flt(&$2, NULL, true); /* Cast the values to float for easier validations */
                        $$.val_type = FLOAT_TYPE; 
                        if(cos($2.fval) < 0.000001 && cos($2.fval) > -0.000001) $$.fval = 0;  /* Values really close to 0 get treated as 0 */
                        else $$.fval = cos($2.fval);  /* calculate cos(x) */
                        sprintf($$.temp, "$t%03d", c3aOpCount++);
                        sprintf(c3a_mssg, "%s := COS %s", $$.temp, $2.temp);
                        c3a(c3a_mssg);
                    }
                }
    | TAN expr4 { 
                    /* Booleans and Strings cannot be used in trigonometric expressions */
                    if ($2.val_type == BOOL_TYPE) 
                        custom_err_mssg("tan() cannot take a type 'Boolean' as a parameter");
                    else if ($2.val_type == STRING_TYPE) 
                        custom_err_mssg("tan() cannot take a type 'String' as a parameter");
                    else {
                        cast_vals_to_flt(&$2, NULL, true);  /* Cast the values to float for easier validations */
                        if(cos($2.fval) < 0.000001) 
                            custom_err_mssg("Indefinition error");  /* tan(x) == sin(x)/cos(x) so if cos(x) == 0, we would be dividing by 0 */
                        else { 
                            $$.val_type = FLOAT_TYPE; 
                            $$.fval = sin($2.fval)/cos($2.fval);  /* calculate tan(x) */
                            sprintf($$.temp, "$t%03d", c3aOpCount++);
                            sprintf(c3a_mssg, "%s := TAN %s", $$.temp, $2.temp);
                            c3a(c3a_mssg);
                        }
                    }
                }
    | NOT expr4 { /* Only booleans can use the or operator */
                    if ($2.val_type != BOOL_TYPE) 
                        custom_err_mssg("Not (not) operator can only be applied to type 'Boolean'");
                    else { 
                        $$.val_type = BOOL_TYPE;
                        $$.bval = !$2.bval;
                        sprintf($$.temp, "$t%03d", c3aOpCount++);
                        sprintf(c3a_mssg, "%s := NOT %s", $$.temp, $2.temp);
                        c3a(c3a_mssg); 
                    }
                }
    | expr4
;

expr4:
    LEN OP expr4 CP { /* Can only use LEN() with a string */
                        if ($3.val_type == STRING_TYPE) {  
                            $$.val_type = INT_TYPE; 
                            $$.ival = strlen($3.sval);
                            sprintf($$.temp, "$t%03d", c3aOpCount++);
                            sprintf(c3a_mssg, "%s := %i", $$.temp, $$.ival);
                            c3a(c3a_mssg);
                        }
                        else { 
                            to_str = type_to_str($3.val_type);
                            sprintf(err_mssg, "LEN(String str) 1st parameter expects type 'String' but it got type '%s'", to_str); 
                            free(to_str);
                            custom_err_mssg(err_mssg); 
                        }
                    }
    | SUBSTR OP expr4 expr4 expr4 CP    { /* Can only use SUBSTR() with a string */
                                            if ($3.val_type != STRING_TYPE) { 
                                                to_str = type_to_str($3.val_type);
                                                sprintf(err_mssg, "SUBSTR(String str, Int start, Int length) 1st parameter expects type 'String' but it got type '%s'", to_str); 
                                                custom_err_mssg(err_mssg); 
                                            }
                                            else if ($4.val_type != INT_TYPE) { 
                                                to_str = type_to_str($4.val_type);
                                                sprintf(err_mssg, "SUBSTR(String str, Int start, Int length) 2nd parameter expects type 'Integer' but it got type '%s'", to_str); 
                                                custom_err_mssg(err_mssg); 
                                            }
                                            else if ($5.val_type != INT_TYPE) { 
                                                to_str = type_to_str($5.val_type);
                                                sprintf(err_mssg, "SUBSTR(String str, Int start, Int length) 3rd parameter expects type 'Integer' but it got type '%s'", to_str); 
                                                custom_err_mssg(err_mssg); 
                                            }
                                            else {
                                                char *str = (char *)malloc($5.ival + 2); /* Ensure enough memory for the final substring */
                                                memcpy(str, $3.sval+$4.ival, $5.ival); 
                                                str[$5.ival] = '\0';
                                                $$.val_type = STRING_TYPE; 
                                                $$.sval = str;
                                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                                sprintf(c3a_mssg, "%s := %s", $$.temp, str);
                                                c3a(c3a_mssg);
                                            }
                                            free(to_str);
                                        }
    | CAST expr_term        {
                                explicit_cast_value(&$2, $1);
                                $$.val_type = $2.val_type;
                                $$.ival = $2.ival;
                                $$.fval = $2.fval;
                                $$.sval = $2.sval;
                                $$.bval = $2.bval;
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s %s", $$.temp, $1, $2.temp);
                                c3a(c3a_mssg);
                            }
    | expr4 HIG expr_term   { /* Booleans and Strings cannot use the higher operator */
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                                    custom_err_mssg("Higher (>) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) 
                                    custom_err_mssg("Higher (>) operator cannot be applied to type 'String'");
                                else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) {
                                    cast_vals_to_flt(&$1, &$3, false); 
                                    $$.val_type = BOOL_TYPE; 
                                    $$.bval = $1.fval > $3.fval;
                                    sprintf($$.temp, "$t%03d", c3aOpCount++);
                                    sprintf(c3a_mssg, "%s := %s GTF %s", $$.temp, $1.temp, $3.temp);
                                    c3a(c3a_mssg);
                                } else {
                                    $$.val_type = BOOL_TYPE; 
                                    $$.bval = $1.ival > $3.ival;
                                    sprintf($$.temp, "$t%03d", c3aOpCount++);
                                    sprintf(c3a_mssg, "%s := %s GTI %s", $$.temp, $1.temp, $3.temp);
                                    c3a(c3a_mssg);
                                }
                            }
    | expr4 HEQ expr_term   { /* Booleans and Strings cannot use the higher or equal operator */
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                                    custom_err_mssg("Higher or equal (>=) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) 
                                    custom_err_mssg("Higher or equal (>=) operator cannot be applied to type 'String'");
                                else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) {
                                    cast_vals_to_flt(&$1, &$3, false); 
                                    $$.val_type = BOOL_TYPE; 
                                    $$.bval = $1.fval >= $3.fval;
                                    sprintf($$.temp, "$t%03d", c3aOpCount++);
                                    sprintf(c3a_mssg, "%s := %s GEF %s", $$.temp, $1.temp, $3.temp);
                                    c3a(c3a_mssg);
                                } else {
                                    $$.val_type = BOOL_TYPE; 
                                    $$.bval = $1.ival >= $3.ival;
                                    sprintf($$.temp, "$t%03d", c3aOpCount++);
                                    sprintf(c3a_mssg, "%s := %s GEI %s", $$.temp, $1.temp, $3.temp);
                                    c3a(c3a_mssg);
                                }
                            }
    | expr4 LOW expr_term   { /* Booleans and Strings cannot use the lower operator */
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                                    custom_err_mssg("Lower (<) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) 
                                    custom_err_mssg("Lower (<) operator cannot be applied to type 'String'");
                                else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) {
                                    cast_vals_to_flt(&$1, &$3, false); 
                                    $$.val_type = BOOL_TYPE; 
                                    $$.bval = $1.fval < $3.fval;
                                    sprintf($$.temp, "$t%03d", c3aOpCount++);
                                    sprintf(c3a_mssg, "%s := %s LTF %s", $$.temp, $1.temp, $3.temp);
                                    c3a(c3a_mssg);
                                } else {
                                    $$.val_type = BOOL_TYPE; 
                                    $$.bval = $1.ival < $3.ival;
                                    sprintf($$.temp, "$t%03d", c3aOpCount++);
                                    sprintf(c3a_mssg, "%s := %s LTI %s", $$.temp, $1.temp, $3.temp);
                                    c3a(c3a_mssg);
                                }
                            }
    | expr4 LEQ expr_term   { /* Booleans and Strings cannot use the lower or equal operator */
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                                    custom_err_mssg("Lower or equal (<=) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) 
                                    custom_err_mssg("Lower or equal (<=) operator cannot be applied to type 'String'");
                                else if ($1.val_type == FLOAT_TYPE || $3.val_type == FLOAT_TYPE) {
                                    cast_vals_to_flt(&$1, &$3, false); 
                                    $$.val_type = BOOL_TYPE; 
                                    $$.bval = $1.fval <= $3.fval;
                                    sprintf($$.temp, "$t%03d", c3aOpCount++);
                                    sprintf(c3a_mssg, "%s := %s LEF %s", $$.temp, $1.temp, $3.temp);
                                    c3a(c3a_mssg);
                                } else {
                                    $$.val_type = BOOL_TYPE; 
                                    $$.bval = $1.ival <= $3.ival;
                                    sprintf($$.temp, "$t%03d", c3aOpCount++);
                                    sprintf(c3a_mssg, "%s := %s LEI %s", $$.temp, $1.temp, $3.temp);
                                    c3a(c3a_mssg);
                                }
                            }
    | expr4 EQU expr_term   { /* Booleans and Strings cannot use the equal operator */
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                                    custom_err_mssg("Equal (==) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) 
                                    custom_err_mssg("Equal (==) operator cannot be applied to type 'String'");
                                cast_vals_to_flt(&$1, &$3, false); 
                                $$.val_type = BOOL_TYPE; 
                                $$.bval = $1.fval == $3.fval;
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s EQ %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            }
    | expr4 NEQ expr_term   { /* Booleans and Strings cannot use the not equal operator */
                                if ($1.val_type == BOOL_TYPE || $3.val_type == BOOL_TYPE) 
                                    custom_err_mssg("Not equal (<>) operator cannot be applied to type 'Boolean'");
                                else if ($1.val_type == STRING_TYPE || $3.val_type == STRING_TYPE) 
                                    custom_err_mssg("Not equal (<>) operator cannot be applied to type 'String'");
                                cast_vals_to_flt(&$1, &$3, false); 
                                $$.val_type = BOOL_TYPE; 
                                $$.bval = $1.fval != $3.fval;
                                sprintf($$.temp, "$t%03d", c3aOpCount++);
                                sprintf(c3a_mssg, "%s := %s NE %s", $$.temp, $1.temp, $3.temp);
                                c3a(c3a_mssg);
                            }
    | expr_term
;

expr_term:
    INT     {
                $$.val_type = INT_TYPE; 
                $$.ival = $1; 
                sprintf($$.temp, "%d", $1);
            }
    | FLOAT {
                $$.val_type = FLOAT_TYPE; 
                $$.fval = $1;
                sprintf($$.temp, "%g", $1);
            }
    | BOOL  {
                $$.val_type = BOOL_TYPE; 
                $$.bval = $1;
                sprintf($$.temp, "%s", ($1 == 0) ? "false" : "true");
            }      
    | STRING    {
                    $$.val_type = STRING_TYPE; 
                    $$.sval = $1;
                    sprintf($$.temp, "%s", $1);
                }
    | PI    {  
                $$.val_type = FLOAT_TYPE; 
                $$.fval = PI_CONST;
                sprintf($$.temp, "%g", PI_CONST);
            }
    | E     {  
                $$.val_type = FLOAT_TYPE; 
                $$.fval = E_CONST;
                sprintf($$.temp, "%g", E_CONST);
            }
    | ID    {
                int result = sym_lookup($1.name, &$1);
                if(result == 0) {
                    $$.val_type = $1.id_val.val_type;
                    if($1.id_val.val_type == INT_TYPE) $$.ival = $1.id_val.ival;
                    else if($1.id_val.val_type == FLOAT_TYPE) $$.fval = $1.id_val.fval;
                    else if($1.id_val.val_type == BOOL_TYPE) $$.bval = $1.id_val.bval;
                    else if($1.id_val.val_type == STRING_TYPE) $$.sval = $1.id_val.sval;
                    sprintf($$.temp, "%s", $1.name);
                }
                else {
                    sprintf(err_mssg, "Variable '%s' does not exist", $1.name); 
                    custom_err_mssg(err_mssg);
                }
            }
    | ID OB expr CB {
                        if ($3.val_type == INT_TYPE) {
                            char arrayName[128];
                            sprintf(arrayName, "%s[%d]", $1.name, $3.ival);
                            int result = sym_lookup(arrayName, &$1);
                            if(result == 0) {
                                $$.val_type = $1.id_val.val_type;
                                if($1.id_val.val_type == INT_TYPE) $$.ival = $1.id_val.ival;
                                else if($1.id_val.val_type == FLOAT_TYPE) $$.fval = $1.id_val.fval;
                                else if($1.id_val.val_type == BOOL_TYPE) $$.bval = $1.id_val.bval;
                                else if($1.id_val.val_type == STRING_TYPE) $$.sval = $1.id_val.sval;
                                sprintf($$.temp, "%s[%d]", $1.name, $3.ival);
                            }
                            else {
                                sprintf(err_mssg, "Array element '%s' does not exist", arrayName); 
                                custom_err_mssg(err_mssg);
                            }
                        }
                        else {
                            to_str = type_to_str($3.val_type);
                            sprintf(err_mssg, "Array cannot be accessed using type '%s' for indexing. Only type 'Integer'", to_str); 
                            free(to_str);
                            custom_err_mssg(err_mssg);
                        }
                    }
    | OP expr CP    { 
                        $$.val_type = $2.val_type;
                        if ($2.val_type == INT_TYPE) 
                            $$.ival = $2.ival;
                        else if ($2.val_type == FLOAT_TYPE) 
                            $$.fval = $2.fval;
                        else if ($2.val_type == BOOL_TYPE) 
                            $$.bval = $2.bval;
                        else 
                            $$.sval = $2.sval;
                        sprintf($$.temp, "%s", $2.temp);
                    }
;
%%

int contains(char *vars[], int size, const char *value) {
    int i;
    for (i = 0; i < size; i++) {
        if (vars[i] != NULL && strcmp(vars[i], value) == 0) {
            return 1;
        }
    }
    return 0;
}

void cast_vals_to_flt(value_info *op1, value_info *op2, bool store3ac) {
    if (op1 != NULL) {
        if (op1->val_type == INT_TYPE) {
            op1->fval = (float)op1->ival;
            if (store3ac) {
                sprintf(c3a_mssg, "$t%03d := I2F %s", c3aOpCount++, op1->temp);
                sprintf(op1->temp, "$t%03d", c3aOpCount-1);
                c3a(c3a_mssg);
            }
        }
    }
    if (op2 != NULL) {
        if (op2->val_type == INT_TYPE) {
            op2->fval = (float)op2->ival;
            if (store3ac) {
                sprintf(c3a_mssg, "$t%03d := I2F %s", c3aOpCount++, op2->temp);
                sprintf(op2->temp, "$t%03d", c3aOpCount-1);
                c3a(c3a_mssg);
            }
        }
    }
}

void custom_err_mssg(const char *s) {
    err = true;
    if (error_log == NULL) {
        error_log = fopen("logs/error_log.txt", "w");
        if (!error_log) {
            fprintf(stderr, "Error: Could not open error_log.txt for writing.\n");
            return;
        }
    }
    printf("ERROR\n");
    fprintf(error_log, "%s\n", input);
    fprintf(error_log, "Error at line %d: %s\n", yylineno, s);
    fflush(error_log);
}

void c3a(const char *s) {
    if (out3ac == NULL) {
        out3ac = fopen("intermediate/c3a.txt", "w");
        if (!out3ac) {
            fprintf(stderr, "Error: Could not open c3a.txt for writing.\n");
            return;
        }
    }
    c3aLines++;
    if (loopIndex >= 0 && !writtingBufferToFile) {
        sprintf(loopBuffer[loopIndex][loopBufferIndex[loopIndex]], "%s", s);
        loopBufferIndex[loopIndex]++;
    } else {
        c3aLineNo++;
        fprintf(out3ac, "%d: %s\n", c3aLineNo, s);
        fflush(out3ac);
    }
}

int yywrap() {
    return 1;
}