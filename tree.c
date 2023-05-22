#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node node;
struct Node
{
	struct Node *prnt;
	struct Node *r;
	struct Node *l;
	char symbol;
};

node home;
node terminal;

void set_symbol(node *x, char c)
{
	x->symbol = c;
}

/* opt = 'l'or'r'. This func add chld to parent's opt side*/
void add_child(node *parent, node *chld, char opt)
{
	chld->prnt = parent;
	if (opt == 'r')
	{
		parent->r = chld;
	}
	else if (opt == 'l')
	{
		parent->l = chld;
	}
}

/* opt = 'l'or'r'. This func add symbl symbol chld to parent's opt side*/
void add_child_char(node *prnt, char symbl, char opt)
{
	node *chld = (node *)malloc(sizeof(node));
	if (chld == NULL)
	{
		printf("System failed to allocate memory.");
		exit(1);
	}
	chld->symbol = symbl;
	chld->r = &terminal;
	chld->l = &terminal;
	add_child(prnt, chld, opt);
}

void print_symbol(node *parent)
{
	printf("%c\n", parent->symbol);
}

/* This func prints the structure of the tree whose root is arg with brackets.*/
void print_tree(node *root)
{
	if (root == &terminal)
	{
		return;
	}

	if (root->l != &terminal)
	{
		printf("(");
	}

	print_tree(root->l);

	if (root->l != &terminal)
	{
		printf(")");
	}

	printf("%c", root->symbol);

	if (root->r != &terminal)
	{
		printf("(");
	}

	print_tree(root->r);

	if (root->r != &terminal)
	{
		printf(")");
	}
	return;
}

void copy_symbol(node *dest, node *src)
{
	dest->symbol = src->symbol;
}

/* This func copy tree. This distinct tree by root node address.*/
void copy_tree(node *dest, node *src)
{
	node *p;
	copy_symbol(dest, src);

	if (src->l != &terminal)
	{
		p = (node *)malloc(sizeof(node));
		p->r = &terminal;
		p->l = &terminal;

		add_child(dest, p, 'l');
		copy_tree(dest->l, src->l);
	}
	else
	{
		dest->l = &terminal;
	}
	if (src->r != &terminal)
	{

		p = (node *)malloc(sizeof(node));
		p->r = &terminal;
		p->l = &terminal;

		add_child(dest, p, 'r');
		copy_tree(dest->r, src->r);
	}
	else
	{
		dest->r = &terminal;
	}
}

/* This func make the demo tree whose root is home*/
void test_tree()
{
	/* (((e)c)a(d))$(b(f)) */
	add_child_char(&home, 'a', 'l');
	add_child_char(&home, 'b', 'r');
	add_child_char(home.l, 'c', 'l');
	add_child_char(home.l, 'd', 'r');
	add_child_char((home.l)->r, 'e', 'l');
	add_child_char(home.r, 'f', 'r');
}

int main()
{
	node home2;
	home2.symbol = '%';
	home2.r = &terminal;
	home2.l = &terminal;

	set_symbol(&home, '$');
	home.r = &terminal;
	home.l = &terminal;

	print_symbol(&home);
	printf("%zu\n", sizeof(node));
	test_tree();
	print_tree(&home);
	printf("\n");

	copy_tree(&home2, &home);
	print_tree(&home2);
	printf("\n");

	copy_tree(((home2.l)->r)->l, &home);
	print_tree(&home2);
	printf("\n");
	return 0;
}
