%code top {
  #include <assert.h>
  #include <ctype.h>  /* isdigit. */
  #include <stdio.h>  /* printf. */
  #include <stdlib.h> /* abort. */
  #include <string.h> /* strcmp. */
  #include "tree.h"

  node home;
  node terminal;

  int yylex (void);
  void yyerror (char const *);
}


//%define api.header.include {"calc.h"}

/* Generate YYSTYPE from the types used in %token and %type.  */
%define api.value.type union
%token <char> VAR
%type  <node *> expr
%type <node *> abst
%type <node *> appl

%left '.'
%left APPL

/* Generate the parser description file (calc.output).  */
%verbose

/* Nice error messages with details. */
%define parse.error detailed

/* Enable run-time traces (yydebug).  */
%define parse.trace

/* Formatting semantic values in debug traces.  */
%printer { fprintf (yyo, "%c", $$->symbol); } <node *>;


%% /* The grammar follows.  */

input:
  %empty
| input line
;

line:
'\n'
| expr '\n'  { print_tree($1); }
| error '\n' { yyerrok; }
;

expr: abst
| appl
;

abst: '\\' VAR '.' abst 
{
  node *n = make_node('.');
  node *c = make_node($2);
  add_child(n,c,'l');
  add_child(n,$4,'r');
  $$ = n;
}

| '\\' VAR '.' appl 
{
  node *n = make_node('.');
  node *c = make_node($2);
  add_child(n,c,'l');
  add_child(n,$4,'r');
  $$ = n;
}

appl: VAR {$$ = make_node($1);}
| abst abst %prec APPL
{
  node *n = make_node('&');
  add_child(n,$1,'l');
  add_child(n,$2,'r');
  $$ = n;
}

|appl abst %prec APPL
{
  node *n = make_node('&');
  add_child(n,$1,'l');
  add_child(n,$2,'r');
  $$ = n;
}

| '(' abst ')' appl %prec APPL
{
  node *n = make_node('&');
  add_child(n,$2,'l');
  add_child(n,$4,'r');
  $$ = n;
}
  

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
    case '.':
    case '\\':
    case ')':
    case '(':
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
