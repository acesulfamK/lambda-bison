%code top {
  #include <assert.h>
  #include <ctype.h>  /* isdigit. */
  #include <stdio.h>  /* printf. */
  #include <stdlib.h> /* abort. */
  #include <string.h> /* strcmp. */
  #include "tree.h"

  node home;
  node terminal;

  char input[80];
  char *pointer;
  int yylex (void);
  void yyerror (char const *);
  FILE* file;
}


//%define api.header.include {"calc.h"}

/* Generate YYSTYPE from the types used in %token and %type.  */
%define api.value.type union
%token <char> VAR
%type <node *> abstvars
%type  <node *> expr
%type <node *> abst
%type <node *> appl
%type <node *> vars

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
| expr '\n'  { 
  print_tree($1);
  printf("\n"); 
  fclose(file); }
| error '\n' { yyerrok; }
;

expr: abst
| appl
| vars
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
| '\\' abstvars '.' vars
{
  node *i;
  for(i = $2;i->r != &terminal; i = i->r);
  add_child(i,$4,'r');
  $$ = $2;
}


abstvars: vars {
  node *n = make_node('.');
  add_child(n,$1,'l');
  $$ = n;
}
| abstvars vars
{
  node *i;
  node *ab = make_node('.');
  for(i = $1;i->r !=&terminal;i=i->r);
  add_child(i,ab,'r');
  add_child(ab,$2,'l');
  $$ = $1;
}

appl: '(' appl ')' {$$ = $2;}
|vars vars %prec APPL
{
  node *n = make_node('&');
  add_child(n,$1,'l');
  add_child(n,$2,'r');
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

| vars '(' appl ')' %prec APPL
{
  node *n = make_node('&');
  add_child(n,$1,'l');
  add_child(n,$3,'r');
  $$ = n;
}

| vars abst %prec APPL
{
  node *n = make_node('&');
  add_child(n,$1,'l');
  add_child(n,$2,'r');
  $$ = n;
}

| appl vars %prec APPL
{
  node *n = make_node('&');
  add_child(n,$1,'l');
  add_child(n,$2,'r');
  $$ = n;
}

| '(' abst ')' vars %prec APPL
{
  node *n = make_node('&');
  add_child(n,$2,'l');
  add_child(n,$4,'r');
  $$ = n;
}
;

vars : VAR {$$ = make_node($1);}
| '(' vars ')' {$$ = $2;}
;

%%

int
yylex (void)
{
  int c;

  /* Ignore white space, get first nonwhite character.  */
  c = *pointer;
  pointer++;

  while (c == ' ' || c == '\t'){
    c = *pointer;
    pointer++;
    continue;
  }

  if (c == '\0')
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
  pointer = input;
  if(argc == 2){
    file  = fopen(argv[1],"r");
    if(fgets(input,99,file)== NULL){
      printf("fgets error");
      exit(1);
    }
  } else {
    printf("Args are invalid\n");
  }

  /* Enable parse traces on option -p.  */
  for (int i = 1; i < argc; ++i)
    if (!strcmp (argv[i], "-p"))
      yydebug = 1;
  return yyparse ();
}
