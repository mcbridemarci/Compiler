%{
#include <stdio.h>
#include <string.h>                                                                          
#include "parser.tab.h"
#include "scanType.h"

//Inform bison about flex things
extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern int line_num;

//Error function
void yyerror(const char* s);
%}

//Use a union to hold possible token data types
%union {
	Token t;
	int temp;
}

//Associate value tokens with union fields
//%token <t> ID NUMBER CHARACTER BOOLEAN RECORD
%token <temp> ENDL AND OR NOT EQ NOTEQ LESSEQ GRTEQ LESS GRT INC DEC ADDASS
%token <temp> SUBASS MULTASS DIVASS SUB PLUS MULT DIV MOD ASS NUMCONST BREAK
%token <temp> BOOLCONST CHARCONST RECTYPE

%type <temp> program tokens token
%start program
%%

program:
      tokens
      ;

tokens:
      tokens token
      | token
      ;

token:
     ENDL
     | AND
     | OR
     | NOT
     | EQ
     | NOTEQ
     | LESSEQ
     | GRTEQ
     | LESS
     | GRT
     | INC
     | DEC
     | ADDASS
     | SUBASS
     | MULTASS
     | DIVASS
     | PLUS
     | SUB
     | MULT
     | DIV
     | MOD
     | ASS
     | NUMCONST
     | BREAK
     | BOOLCONST
     | CHARCONST
     | RECTYPE
     ;

%%

int main(int argc, char** argv) {

	//Open file handle to read input
	FILE* myfile;

        if (argc > 1) {
            myfile = fopen(argv[1], "r");
	        if(!myfile) {
                    printf("Excuse me, I can't read your c- file!\n");
        		return(-1);
	        }
        } else {
            myfile = stdin;
        }

	//Tell bison to read from file stream
	yyin = myfile;

	//Parse the input
	do{
		yyparse();
	}while(!feof(yyin));
}

void yyerror(const char* s) {

	int i = 0;
	yylval.sval = strdup(yytext);
	for (i = 0; i < strlen(yylval.sval); i++)
		printf("ERROR(%d): Invalid or misplaced input character: \"%c\"\n",line_num, yylval.sval[i]);
	return;
}
