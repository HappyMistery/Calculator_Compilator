/***************************************************/
/*                 LEX SPECIFICATION               */
/***************************************************/
%{
    #include "bison_spec.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>

    void yyerror(char *s);
%}

/******************* DEFINITIONS *******************/
INT [0-9]+
EXP [eE]-?[0-9]+
FLOAT [0-9]+"."[0-9]+{EXP}?
STRING \"[^\n"]*\"
BOOL ("TRUE"|"FALSE"|[01])
COMM (("//"|"#")[^\n]*)|("/*"([^*]|\*+[^*/])**"*/")
ID [a-zA-Z_][a-zA-Z0-9_]*
ASSIGN ":="

PI   [Pp][Ii]
E    [Ee]
/********************** RULES **********************/
%% 
{INT}       { yylval.ival = atoi(yytext); return INT; }
{EXP}       { yylval.fval = atof(yytext); return FLOAT; }
{FLOAT}     { yylval.fval = atof(yytext); return FLOAT; }
{STRING}    { return STRING; }
{BOOL}      { return BOOL; }
{COMM}      { return COMM; }
"PI"        { return PI; }
"E"         { return E; }
{ID}        { yylval.sval = strdup(yytext); return ID; }
":="        { return ASSIGN; }
"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }
"("         { return '('; }
")"         { return ')'; }

\n          { return '\n'; }
[ \t\r]+    { /* Ignore whitespace */ }

.           { printf("UNKNOWN: %s\n", yytext); }
%%
/******************** USER CODE ********************/