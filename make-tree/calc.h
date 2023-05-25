#ifndef CALC
#define CALC

typedef struct Node
{
    struct Node *prnt;
    struct Node *r;
    struct Node *l;
    char symbol;
} node;

extern node home;
extern node terminal;

char *char2string(char x);
char *add_string(char *x, char *y);

void set_symbol(node *x, char c);

/* opt = 'l'or'r'. This func add chld to parent's opt side*/
void add_child(node *parent, node *chld, char opt);
/* opt = 'l'or'r'. This func add symbl symbol chld to parent's opt side*/
void add_child_char(node *prnt, char symbl, char opt);
void print_symbol(node *parent);

/* This func prints the structure of the tree whose root is arg with brackets.*/
void print_tree(node *root);
void copy_symbol(node *dest, node *src);

/* This func copy tree. This distinct tree by root node address.*/
void copy_tree(node *dest, node *src);
/* This func make the demo tree whose root is home*/
void test_tree();

#endif
