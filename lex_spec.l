/***************************************************/
/*                 LEX SPECIFICATION               */
/***************************************************/
%{
    #include "bison_spec.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include <unistd.h>
    #include <math.h>

    void yyerror(char *s);
%}

/******************* DEFINITIONS *******************/
INT [0-9]+
EXP [eE]-?[0-9]+
FLOAT [0-9]+"."[0-9]+{EXP}?
STRING \"[^\n"]*\"
BOOL ("true"|"false"|[01])
COMM (("//"|"#")[^\n]*)|("/*"([^*]|\*+[^*/])**"*/")
ID [a-zA-Z_][a-zA-Z0-9_]*
/********************** RULES **********************/
%%

"not"       { return NOT; }
"and"       { return AND; }
"or"        { return ORR; }
"PI"        { return PI; }
"E"         { return E; }

{INT}       { yylval.ival = atoi(yytext); return INT; }
{EXP}       { yylval.fval = atof(yytext); return FLOAT; }
{FLOAT}     { yylval.fval = atof(yytext); return FLOAT; }
{STRING}    { yylval.sval = yytext; return STRING; }
{BOOL}      { yylval.ival = (strcmp(yytext, "true") == 0) ? 1 : 0; return BOOL; }

{ID}        { yylval.sval = strdup(yytext); return ID; }
{COMM}      { return COMM; }

":="        { return ASSIGN; }

"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }
"%"         { return MOD; }
"**"        { return POW; }

">"         { return HIG; }
">="        { return HEQ; }
"<"         { return LOW; }
"<="        { return LEQ; }
"=="        { return EQU; }
"<>"        { return NEQ; }

"("         { return '('; }
")"         { return ')'; }

\n          { return '\n'; }
[ \t\r]+    { /* Ignore whitespace */ }

.           { printf("UNKNOWN: %s\n", yytext); }
%%
/******************** USER CODE ********************/