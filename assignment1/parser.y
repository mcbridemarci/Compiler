%{
#define YYPARSER
//#define YYERROR_VERBOSE 1
#include <stdio.h>
#include <string.h>
#include "scanType.h"                                                                          
#include "parser.tab.h"

//Inform bison about flex things
extern int yylex();
extern int yyparse();
extern char* yytext;
extern FILE* yyin;
extern int line_num;

//Error function
void yyerror(const char* s);
%}

//Use a union to hold possible token data types
%union {
	Token token;
	int temp;
}

//Associate value tokens with union fields
//%token <t> ID NUMBER CHARACTER BOOLEAN RECORD
%token <token> ENDL AND OR NOT EQ NOTEQ LESSEQ GRTEQ LESS GRT INC DEC ADDASS SUBASS MULTASS DIVASS SUB PLUS MULT DIV MOD ASS NUMCONST BREAK BOOLCONST CHARCONST RECTYPE STATIC BOOL RETURN WHILE IN INT IF ELSE CHAR ID NUMBER CHARACTER BOOLEAN KEYWORD RECORD SYMBOL 

%type <temp> program words word
%start program
%%

program:
      words 
      ;

words:
      words word
      | word 
      ;

word:
     ENDL {;}
     | AND {printf("Line %d Token: AND\n", $1.line_num);}
     | OR {printf("Line %d Token: OR\n", $1.line_num);}
     | NOT {printf("Line %d Token: NOT\n", $1.line_num);}
     | EQ {printf("Line %d Token: EQ\n", $1.line_num);}
     | NOTEQ {printf("Line %d Token: NOTEQ\n", $1.line_num);}
     | LESSEQ {printf("Line %d Token: LESSEQ\n", $1.line_num);}
     | GRTEQ {printf("Line %d Token: GRTEQ\n", $1.line_num);}
     | LESS {printf("Line %d Token: <\n", $1.line_num);}
     | GRT {printf("Line %d Token: >\n", $1.line_num);}
     | INC {printf("Line %d Token: INC\n", $1.line_num);}
     | DEC {printf("Line %d Token: DEC\n", $1.line_num);}
     | ADDASS {printf("Line %d Token: ADDASS\n", $1.line_num);}
     | SUBASS {printf("Line %d Token: SUBASS\n", $1.line_num);}
     | MULTASS {printf("Line %d Token: MULASS\n", $1.line_num);}
     | DIVASS {printf("Line %d Token: DIVASS\n", $1.line_num);}
     | PLUS {printf("Line %d Token: +\n", $1.line_num);}
     | SUB {printf("Line %d Token: -\n", $1.line_num);}
     | MULT {printf("Line %d Token: *\n", $1.line_num);}
     | DIV {printf("Line %d Token: /\n", $1.line_num);}
     | MOD {printf("Line %d Token: %\n", $1.line_num);}
     | ASS {printf("Line %d Token: =\n", $1.line_num);}
     | NUMCONST {printf("Line %d Token: NUMCONST Value: %d  Input: %s\n",
                     $1.line_num,$1.num,$1.raw_str);}
     | BREAK {printf("Line %d Token: BREAK\n", $1.line_num);}
     | BOOL {printf("Line %d Token: BOOL\n", $1.line_num);}
     | RECTYPE {printf("Line %d Token: ID Value: %s\n", $1.line_num,$1.raw_str);}
     | RECORD {printf("Line %d Token: RECORD\n", $1.line_num);}
     | STATIC {printf("Line %d Token: STATIC\n", $1.line_num);}
     | RETURN {printf("Line %d Token: RETURN\n", $1.line_num);}
     | WHILE {printf("Line %d Token: WHILE\n", $1.line_num);}
     | IN {printf("Line %d Token: IN\n", $1.line_num);}
     | INT {printf("Line %d Token: INT\n", $1.line_num);}
     | ELSE {printf("Line %d Token: ELSE\n", $1.line_num);}
     | IF {printf("Line %d Token: IF\n", $1.line_num);}
     | CHAR {printf("Line %d Token: CHAR\n", $1.line_num);}
     | ID {printf("Line %d Token: ID Value: %s\n", $1.line_num,$1.raw_str);}
     | CHARCONST {
                    printf("Line %d Token: CHARCONST Value: '%c'  Input: %s\n",
                     $1.line_num,$1.c,$1.raw_str);
                  }
     | BOOLCONST {printf("Line %d Token: BOOLCONST Value: %d  Input: %s\n", $1.line_num,$1.num,$1.raw_str);}
     | SYMBOL {printf("Line %d Token: %s\n", $1.line_num,$1.raw_str);}
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
    fprintf(stderr, "hello errors! --  %s\n", s);
	return;
}
