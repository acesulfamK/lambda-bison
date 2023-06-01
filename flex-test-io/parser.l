%{
#include <stdio.h>

/* 字句（トークン）の種類を定義 */
enum {NUMBER = 1, STRING};

int num; /* 数字列を変換した数値の格納用 */

/* 読み込みファイルが複数ある場合に使用、今は1を返す様にしておく */
int yywrap(void){return 1; }
void yyerror(char *msg);

%}

%%
[0-9]+                  {sscanf(yytext,"%d",&num); /* パターンに適合すると{ }内のアクションを実行 */
                         return NUMBER;} /* yylex()の戻り値としてNUMBERを返す */

[a-z]+                  {return STRING;} /* yylex()の戻り値としてSTRINGを返す */

" "|"\n"                {}               /* スペース・改行は何もしない */

.                       {yyerror("Illegal character");}/* その他の文字はエラー処理 */
%%
void yyerror(char *msg){ fprintf(yyout, "%s : '%s'\n", msg, yytext); }


int main(int argc, char ** argv){
   int t;

   if ( argc > 2 ){
      /* yyinをファイル入力に切り替え */
      if((yyin = fopen( argv[1], "r")) == NULL){
         fprintf(stderr,"Can't open a input file!\n");
         return 1;
      }

      /* yyoutをファイル出力に切り替え */
      if((yyout = fopen( argv[2], "w")) == NULL){
         fprintf(stderr,"Can't open a output file!\n");
         return 1;
      }
   }


   while((t = yylex()) != 0){
      if(t == NUMBER)
         fprintf(yyout, "kind = %d, string = '%s' length = %d value = %d\n", t, yytext, yyleng, num);
      else if(t == STRING)
         fprintf(yyout, "kind = %d, string = '%s' length = %d\n", t, yytext, yyleng);
      else
         fprintf(yyout, "other TOKEN\n");
   }

   return 0;
}
