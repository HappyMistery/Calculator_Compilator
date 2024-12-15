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
    char expression_buffer[512] = "";
    char* input;

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


    void append_to_buffer(const char* text) {
        strcat(expression_buffer, text);
    }

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
BASE b2|b8|b10|b16
/********************** RULES **********************/
%%

"NOT"|"not"         { append_to_buffer(yytext); return NOT; }
"AND"|"and"         { append_to_buffer(yytext); return AND; }
"OR"|"or"           { append_to_buffer(yytext); return ORR; }
"SIN"|"sin"         { append_to_buffer(yytext); return SIN; }
"COS"|"cos"         { append_to_buffer(yytext); return COS; }
"TAN"|"tan"         { append_to_buffer(yytext); return TAN; }
"LEN"|"len"         { append_to_buffer(yytext); return LEN; }
"SUBSTR"|"substr"   { append_to_buffer(yytext); return SUBSTR; }

"PI"    { append_to_buffer(yytext); return PI; }
"E"     { append_to_buffer(yytext); return E; }

"showVars()"    { append_to_buffer(yytext); return SHVAR; }

"repeat"    { append_to_buffer(yytext); return REP; }
"do"        { append_to_buffer(yytext); return DO; }
"done"      { append_to_buffer(yytext); return DONE; }

{BASE}      { append_to_buffer(yytext); yylval.sval = strdup(yytext); return BASE; }


{INT}       { append_to_buffer(yytext); yylval.ival = atoi(yytext); return INT; }
{EXP}       { append_to_buffer(yytext); yylval.fval = atof(yytext); return FLOAT; }
{FLOAT}     { append_to_buffer(yytext); yylval.fval = atof(yytext); return FLOAT; }
{STRING}    { append_to_buffer(yytext); 
                char *temp = strdup(yytext);
                temp[yyleng - 1] = '\0'; /* eliminar cometes finals canviantles per el delimitador*/
                yylval.sval = strdup(temp + 1); /* eliminar cometes inicials movent el punter a temp en 1 pos */
                free(temp);
                return STRING; 
            }
{BOOL}      { append_to_buffer(yytext); yylval.ival = (strcmp(yytext, "true") == 0) ? 1 : 0; return BOOL; }


{ID}        {   append_to_buffer(yytext); 
                yylval.id.name = strdup(yytext);
                yylval.id.length = yyleng;
                yylval.id.line = yylineno;
                yylval.id.id_val.val_type = UNKNOWN_TYPE;
                yylval.id.base = NO_BASE;
                return ID;
            }
{COMM}      { append_to_buffer(yytext); }

":="        { append_to_buffer(yytext); return ASSIGN; }

"+"         { append_to_buffer(yytext); return ADD; }
"-"         { append_to_buffer(yytext); return SUB; }
"*"         { append_to_buffer(yytext); return MUL; }
"/"         { append_to_buffer(yytext); return DIV; }
"%"         { append_to_buffer(yytext); return MOD; }
"**"        { append_to_buffer(yytext); return POW; }

">"         { append_to_buffer(yytext); return HIG; }
">="        { append_to_buffer(yytext); return HEQ; }
"<"         { append_to_buffer(yytext); return LOW; }
"<="        { append_to_buffer(yytext); return LEQ; }
"=="        { append_to_buffer(yytext); return EQU; }
"<>"        { append_to_buffer(yytext); return NEQ; }

"("         { append_to_buffer(yytext); return OP; }
")"         { append_to_buffer(yytext); return CP; }

\n          {   input = strdup(expression_buffer);
                expression_buffer[0] = '\0';
                current_column = 1; 
                return ENDLINE; }
[ \t\r]+    { /* Ignore whitespace */ }

.           { printf("UNKNOWN: %s\n", yytext); }
%%
/******************** USER CODE ********************/