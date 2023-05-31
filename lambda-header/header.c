#include <stdio.h>
#include "header.h"
#include "tree.h"

char *input;
node home;

int main()
{
    input = "@x.x";
    bison_parse();
    print_tree(home.r);
    printf("\n");
}
