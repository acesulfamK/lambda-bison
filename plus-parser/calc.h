#ifndef CALC
#define CALC

typedef struct Node
{
    struct Node *prnt;
    struct Node *r;
    struct Node *l;
    char symbol;
} node;

char *char2string(char x);
char *add_string(char *x, char *y);

#endif
