%code top {
  #include <assert.h>
  #include <ctype.h>  /* isdigit. */
  #include <stdio.h>  /* printf. */
  #include <stdlib.h> /* abort. */
  #include <string.h> /* strcmp. */
  #include "calc.h"
  node home;
  node terminal;

  int yylex (void);
  void yyerror (char const *);
}


//%define api.header.include {"calc.h"}

/* Generate YYSTYPE from the types used in %token and %type.  */
%define api.value.type union
%token <char> VAR
%type  <char *> expr

/* Generate the parser description file (calc.output).  */
%verbose

/* Nice error messages with details. */
%define parse.error detailed

/* Enable run-time traces (yydebug).  */
%define parse.trace

/* Formatting semantic values in debug traces.  */
%printer { fprintf (yyo, "%s", $$); } <char *>;

%% /* The grammar follows.  */
input:
  %empty
| input line
;

line:
'\n'
| expr '\n'  { printf ("%s\n", $1); }
| error '\n' { yyerrok; }
;

expr:
VAR {$$ = char2string($1);}
| '(' expr '+' expr ')' { $$ = add_string($2,$4);}
;

%%

int
yylex (void)
{
  int c;

  /* Ignore white space, get first nonwhite character.  */
  while ((c = getchar ()) == ' ' || c == '\t')
    continue;

  if (c == EOF)
    return 0;
  

  /* Char starts a number => parse the number.         */
  switch(c){
    case '(':
    case ')':
    case '+':
    case '\n':
    printf("%c:special\n",c);
    return c;
  }
  yylval.VAR = c;
  printf("%c:VAR\n",c);
  return VAR;
  /* Any other character is a token by itself.        */
}

/* Called by yyparse on error.  */
void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}

int
main (int argc, char const* argv[])
{
  /* Enable parse traces on option -p.  */
  for (int i = 1; i < argc; ++i)
    if (!strcmp (argv[i], "-p"))
      yydebug = 1;
  return yyparse ();
}
