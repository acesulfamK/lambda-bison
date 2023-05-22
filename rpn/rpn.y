%{

#include <stdio.h>
#include <ctype.h>
#include <math.h>

#define YYSTYPE double

int yylex(void);
void yyerror(const char* s);

%}

%token NUM

%%

input   : /* empty */
        | input line
;

line    : '\n'
        | expr '\n'
                { printf("\t%.10g\n", $1); }
;

expr    : NUM // By default, {$$ = $1} is used.
        | expr expr '+'
                { $$ = $1 + $2;            }
        | expr expr '-'
                { $$ = $1 - $2;            }
        | expr expr '*'
                { $$ = $1 * $2;            }
        | expr expr '/'
                { $$ = $1 / $2;            }
        | expr expr '^'
                { $$ = pow($1, $2);        }
        | expr 'n'
                { $$ = -$1;                }
;

%%

/* トークン解析関数 */
/*
	c is space => skip
	c is number => return NUM	
	c is character like '+', '-' => return c
*/

int yylex(void)
{
  int c;

  /* 空白、タブは飛ばす */
  while((c = getchar()) == ' ' || c == '\t')
    ;
  /* 数値を切り出す */
  if(c == '.' || isdigit(c))
  {
    ungetc(c, stdin);
    scanf("%lf", &yylval);
    return NUM;
  }
  /* EOF を返す */
  if(c == EOF)
    return 0;
  /* 文字を返す */
  return c;
}

/* エラー表示関数 */
void yyerror(const char* s)
{
  fprintf(stderr, "error: %s\n", s);
}

int main(void)
{
  /* 構文解析関数 yyparse */
  return yyparse();
}
