%{
//Custom dinner with added features! :D
//includes specials and stuff
//Should work on printing maybe?
//Import input/output functions
#include<stdio.h>
//Import string functions
#include<string.h>
//Import token types for returning to Bison
#include "dinner.tab.h"

//Count the lines
int line_num = 1;
%}

letter [a-zA-Z]
number [0-9]
alphanum {letter}|{number}
float {number}+\.{number}+
allergen !{letter}+
chemical {letter}+{number}+


%%

diNNeR			{ return DINNER; }
type			{ return TYPE; }
specials			{ return SPECIALS; }
chemicals			{ return CHEMICALS; }
end			{ return END; }


\n			{ ++line_num; return ENDL; }
[ \t]			;
{float}		{ yylval.fval = atof(yytext); return FLOAT; }
{number}+			{ yylval.ival = atoi(yytext); return INT; }
{allergen}+			{ yylval.sval = strdup(yytext); return ALLERGEN; }
{chemical}+			{ yylval.sval = strdup(yytext); return CHEMICAL; }
{letter}+ {
				//Have to copy string data to avoid drama
				yylval.sval = strdup(yytext);
				return STRING;
			}
.			;

%%

//No subroutine here because bison is taking care of it
