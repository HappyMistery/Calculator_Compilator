/***************************************************/
/*                 LEX SPECIFICATION               */
/***************************************************/
%{
    #include "bison_spec.tab.h"
    #include <stdio.h>
    #include <string.h>

    void yyerror(char *s);

    extern int yylval;
%}
/******************* DEFINITIONS *******************/
INT [0-9]+
EXP e-?[0-9]+
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
{INT}       { yylval = atoi(yytext); return INT; }
{EXP}       { yylval = atoi(yytext); return EXP; }
{FLOAT}     { yylval = atof(yytext); return FLOAT; }
{STRING}    { return STRING; }
{BOOL}      { return BOOL; }
{COMM}      { return COMM; }
"PI"        { return PI; }
"E"         { return E; }
{ID}        { yylval = strdup(yytext); return ID; }
":="        { return ASSIGN; }
[-()+*/]    { return yytext; }

.           { printf("UNKNOWN: %s\n", yytext); }
%%
/******************** USER CODE ********************/