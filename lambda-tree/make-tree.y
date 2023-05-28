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
%type <node *> abstvars
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

abst: '(' abst ')' {$$ = $2;}
| '\\' abstvars '.' abst 
{
  node *i;
  for(i = $2;i->r != &terminal; i = i->r);
  add_child(i,$4,'r');
  $$ = $2;
}

| '\\' abstvars '.' appl 
{
  node *i;
  for(i = $2;i->r != &terminal; i = i->r);
  add_child(i,$4,'r');
  $$ = $2;
}
| '\\' abstvars '.' VAR
{
  node *i;
  for(i = $2;i->r != &terminal; i = i->r);
  add_child(i,make_node($4),'r');
  $$ = $2;
}


abstvars: VAR {
  node *n = make_node('.');
  add_child(n,make_node($1),'l');
  $$ = n;
}
| abstvars VAR
{
  node *i;
  node *ab = make_node('.');
  for(i = $1;i->r !=&terminal;i=i->r);
  add_child(i,ab,'r');
  add_child(ab,make_node($2),'l');
  $$ = $1;
}

appl: '(' appl ')' {$$ = $2;}
|VAR VAR  %prec APPL
{
  node *n = make_node('&');
  add_child(n,make_node($1),'l');
  add_child(n,make_node($2),'r');
  $$ = n;
}

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

| VAR '(' appl ')' %prec APPL
{
  node *n = make_node('&');
  add_child(n,make_node($1),'l');
  add_child(n,$3,'r');
  $$ = n;
}

| VAR abst %prec APPL
{
  node *n = make_node('&');
  add_child(n,make_node($1),'l');
  add_child(n,$2,'r');
  $$ = n;
}

| appl VAR %prec APPL
{
  node *n = make_node('&');
  add_child(n,$1,'l');
  add_child(n,make_node($2),'r');
  $$ = n;
}

| '(' abst ')' VAR %prec APPL
{
  node *n = make_node('&');
  add_child(n,$2,'l');
  add_child(n,make_node($4),'r');
  $$ = n;
}
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
