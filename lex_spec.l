/***************************************************/
/*                 LEX SPECIFICATION               */
/***************************************************/
%{
    #include "bison_spec.tab.h"
    #include "funcions.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include <unistd.h>
    #include <math.h>

    int current_column = 1;

    void yyerror(const char *s);
    #ifndef strdup
    char* strdup(const char* s) {
        char* copy = malloc(strlen(s) + 1);
        if (copy) {
            strcpy(copy, s);
        }
        return copy;
    }
    #endif

    int fileno(FILE *stream);
%}

%option header-file="lex.yy.h"
%option yylineno
%option noyywrap
%option noinput
%option nounput

/******************* DEFINITIONS *******************/
INT [0-9]+
EXP [eE][-+]?[0-9]+
FLOAT [0-9]+"."[0-9]+{EXP}?
STRING \"[^\n"]*\"
BOOL ("true"|"false"|[01])
COMM (("//"|"#")[^\n]*)|("/*"([^*]|\*+[^*/])**"*/")
ID [a-zA-Z_][a-zA-Z0-9_]*
BIN [Bb]2
OCT [Bb]8
DEC [Bb]10
HEX [Bb]16
/********************** RULES **********************/
%%

"not"       { return NOT; }
"and"       { return AND; }
"or"        { return ORR; }
"PI"        { return PI; }
"E"         { return E; }
"sin"       { return SIN; }
"cos"       { return COS; }
"tan"       { return TAN; }
"LEN"       { return LEN; }
"SUBSTR"    { return SUBSTR; }

{OCT}       { return OCT; }
{BIN}       { return BIN; }
{HEX}       { return HEX; }
{DEC}       {}


{INT}       { yylval.ival = atoi(yytext); return INT; }
{EXP}       { yylval.fval = atof(yytext); return FLOAT; }
{FLOAT}     { yylval.fval = atof(yytext); return FLOAT; }
{STRING}    { char *temp = strdup(yytext);
              temp[yyleng - 1] = '\0'; /* eliminar cometes finals canviantles per el delimitador*/
              yylval.sval = strdup(temp + 1); /* eliminar cometes inicials movent el punter a temp en 1 pos */
              free(temp);
              return STRING; 
            }
{BOOL}      { yylval.ival = (strcmp(yytext, "true") == 0) ? 1 : 0; return BOOL; }


{ID}        {
                yylval.id.name = strdup(yytext);
                yylval.id.lenght = yyleng;
                yylval.id.line = yylineno;
                yylval.id.id_val.val_type = UNKNOWN_TYPE;
                yylval.id.mode = NO_MODE;
                return ID;
            }
{COMM}      {}

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

"("         { return OP; }
")"         { return CP; }

\n          { current_column = 1; return ENDLINE; }
[ \t\r]+    { /* Ignore whitespace */ }

.           { printf("UNKNOWN: %s\n", yytext); }
%%
/******************** USER CODE ********************/