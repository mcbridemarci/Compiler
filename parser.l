 //definitions
%{
 // Import input/output functions
#include<stdio.h>
 // Import string functions
#include<string.h>

extern int yylex();
//Count the lines
int line_num = 1;
%}
letter      [a-zA-Z]
digit			  [0-9]
letdig			(letter|digit)
ID			    (letter+letdig*)
NUMCONST		digit+
null			  \0
newline			\n
CHARCONST   '[a-zA-Z0-9]|null|newline '

%%
 //rules section 
[(\/\/)+ .* $]	; // Do nothing for comments
[ \t \n]				; // Grab spaces,  tabs, & new lines and do nothing  
digit           { printf("Found a digit: %s\n", yytext); }
letter           { printf("Found a letter: %s\n", yytext); }
letdig           { printf("Found a letdig: %s\n", yytext); }


%%
 // user subroutine section 
 // No subroutine here because bison is taking care of it
int main(int argc, char **argv)
{
	yylex();
}
