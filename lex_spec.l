/***************************************************/
/*                 LEX SPECIFICATION               */
/***************************************************/

/******************* DEFINITIONS *******************/
INT [0-9]+
EXP e-?[0-9]+
FLOAT [0-9]+"."[0-9]+{EXP}?
STRING \"[^\n"]*\"
BOOL ("TRUE"|"FALSE"|[01])
COMM (("//"|"#")[^\n]*)|("/*"([^*]|\*+[^*/])**"*/")
/********************** RULES **********************/
%% 
{INT}       { printf("INT: %s\n", yytext); }
{EXP}       { printf("EXP: %s\n", yytext); }
{FLOAT}     { printf("FLOAT: %s\n", yytext); }
{STRING}    { printf("STRING: %s\n", yytext); }
{BOOL}      { printf("BOOL: %s\n", yytext); }
{COMM}      { printf("COMM: %s\n", yytext); }



.           { printf("UNKNOWN: %s\n", yytext); }
%%
/******************** USER CODE ********************/
int main(void) {
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}