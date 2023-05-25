#include <stdio.h>
#include "calc.h"

node home;
node terminal;

int main()
{

    node *top = make_node('a');
    node *temp = make_node('b');
    add_child(top, temp, 'l');
    add_child(top, make_node('c'), 'r');
    add_child(temp, make_node('d'), 'r');
    add_child(temp, make_node('e'), 'l');

    print_tree(top);
    printf("\n");
    printf("%zu\n", sizeof(node));
    return 0;
}
