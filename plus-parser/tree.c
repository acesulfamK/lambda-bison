#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "calc.h"

char *char2string(char c)
{
	char *s = (char *)malloc(2);
	*s = c;
	s[1] = '\0';
	return s;
}

char *add_string(char *x, char *y)
{
	char *s = (char *)malloc(strlen(x) + strlen(y) + 4);
	strcpy(s, "[");
	strcat(s, x);
	strcat(s, ",");
	strcat(s, y);
	strcat(s, "]");
	free(x);
	free(y);
	return s;
}
