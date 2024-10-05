%{
  #include <stdio.h>
  int yylex(void);
  void yyerror(const char *s);
%}

%token INT EXP FLOAT STRING BOOL COMM ID ASSIGN PI E

%start calculator

%%

calculator:
    expr
  {
    printf("%d\n", $1);
  }
  | ID ASSIGN expr
  {
    printf("%d\n", $3);
  }
;

expr:
    INT           { $$ = $1; }
  | EXP           { $$ = $1; }
  | FLOAT         { $$ = $1; }
  | BOOL          { $$ = $1; }
  | PI            { $$ = 3.141592653589; }
  | E             { $$ = 2.718281828459; }
  | expr '+' expr { $$ = $1 + $3; }
  | expr '-' expr { $$ = $1 - $3; }
  | expr '*' expr { $$ = $1 * $3; }
  | expr '/' expr { $$ = $1 / $3; }
  | '(' expr ')'  { $$ = $2; }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "\n%s\n", s);
}

int main() {
    printf("Introdueix una expressió:\n");
    return(yyparse());
}

int yywrap() {
  return 1;
}