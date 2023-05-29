# bison構文解析を用いたラムダ計算コンパイラ(未完成)

# BNF

expr :: = ( expr )
    | VAR
    | lfex expr 
    | L abv . expr
lfex ::= expr
abv ::= VAR abv
    | VAR


# ファイル構成

- lambda-file: ラムダ計算をファイルから入力可能。
```
./a.out <ファイル名>
```
改行などの実装が終わっていない。

- only-plus-file: 足し算の演算のみを行うプログラムonly-plusに、ファイルからの入力が可能になった。ファイルの読み込みは以下のよう
```
./a.out <ファイル名>
```

- flex-file-io: flexのdemo。inputファイルの構文を解析しoutputに出す。

- lambda-tree: ラムダ計算式 -> 構文木の完成形
できる計算
```
\ab.c : 複数抽象
\a.bcd : 抽象の括弧省略
\x.y\z.q : 適用の括弧省略
((\x.y)) : 抽象、適用に対する意味の無い括弧の連続
```

できない計算
```
((x)) : 定数に対する意味の無い括弧の連続(将来、importをファイル結合で実装したいなら必要かも)
```

- lambda-tree-uni-var: 変数の連続applyに括弧はいらないが、abtractの際に変数は1文字しか置くことができない。

-strict-lambda-bin-tree: 定数、変数同士のapplyでも括弧が必要なラムダ式

- make-tree: (,+,) を用いた構文から、構造体で定義されたノード同士の参照関係からなる2分木を生成する。
 


- plus-parser: `(+)`を用いて書かれた式の構造を解析し、`[,]`に変換する
例
```
input: (1+(2+3))
output: [1,[2,3]]
```

- only-plus: bison exampleのcalc.yから間引いて、数値+数値、の形をしたコードのみ計算するようにしたもの。.gvファイルを、graphvizで見るために単純なコードにした。これを改変してstring+stringで文字列を結合するようにしたのが、plus-to-string。

- plus-to-string: only-plusを改変して、string+stringを入力したときのみこれらをcatして返すコード

- rpn: RPN(逆ポーランド記法)を処理するbison examplesのコード

- tree.c: 2分木アルゴリズム。ノードを構造体で管理している。

# 考えられる原因とデバッグ方法

yylexエラー
- 正しく形態素に区切れているか -> 文字数のカウントや、型をprintして確かめる。

構文エラー
- %varboseなどを用いてどこの入力がsyntax errorだったかを解析する
- 数値などの単純なtoken(終端記号)を持つ、同じ構造の文法規則を作り、--graphを指定してコンパイルして、.gvファイルのオートマトンを比較する。
