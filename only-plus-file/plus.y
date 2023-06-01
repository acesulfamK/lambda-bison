%code top {
  #include <assert.h>
  #include <ctype.h>  /* isdigit. */
  #include <stdio.h>  /* printf. */
  #include <stdlib.h> /* abort. */
  #include <string.h> /* strcmp. */

  FILE *file;
  int yylex (void);
  void yyerror (char const *);
}

//%define api.header.include {"calc.h"}

/* Generate YYSTYPE from the types used in %token and %type.  */
%define api.value.type union
%token <double> NUM "number"
%type  <double> expr 

/* Generate the parser description file (calc.output).  */
%verbose

/* Nice error messages with details. */
%define parse.error detailed

/* Enable run-time traces (yydebug).  */
%define parse.trace

/* Formatting semantic values in debug traces.  */
%printer { fprintf (yyo, "%g", $$); } <double>;

%% /* The grammar follows.  */
input:
  %empty
| input line
;

line:
'\n'
| expr '\n'  { printf ("%.10g\n", $1); }
| error '\n' { yyerrok; }
;

expr:
  NUM '+' NUM { $$ = $1 + $3; }
;

%%

int
yylex (void)
{
  int c;

  /* Ignore white space, get first nonwhite character.  */
  while ((c = fgetc(file)) == ' ' || c == '\t')
    continue;

  if (c == EOF){
    fclose(file);
    return 0;
  }

  /* Char starts a number => parse the number.         */
  if (c == '.' || isdigit (c))
    {
      yylval.NUM = c - '0';
      return NUM;
    }

  /* Any other character is a token by itself.        */
  return c;
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
  if(argc != 2 ){
    printf("There are not args\n");
    return 1;
  }
  
  file =  fopen(argv[1],"r");
  if (file == NULL) {
      printf("Cannot open file\n");
      return 1;
  }

  /* Enable parse traces on option -p.  */
  for (int i = 1; i < argc; ++i)
    if (!strcmp (argv[i], "-p"))
      yydebug = 1;
  return yyparse ();
}
