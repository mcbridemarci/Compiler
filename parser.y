%{
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
%token <token> ENDL AND OR NOT EQ NOTEQ LESSEQ GRTEQ LESS GRT INC DEC ADDASS
%token <token> SUBASS MULTASS DIVASS SUB PLUS MULT DIV MOD ASS NUMCONST BREAK
%token <token> BOOLCONST CHARCONST RECTYPE STATIC BOOL RETURN WHILE IN INT IF
%token <token> ELSE CHAR
//%token <token> ID NUMBER CHARACTER BOOLEAN KEYWORD RECORD

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
     | AND {;}
     | OR {;}
     | NOT {;}
     | EQ {;}
     | NOTEQ {;}
     | LESSEQ {;}
     | GRTEQ {;}
     | LESS {;}
     | GRT {;}
     | INC {;}
     | DEC {;}
     | ADDASS {;}
     | SUBASS {;}
     | MULTASS {;}
     | DIVASS {;}
     | PLUS {;}
     | SUB {;}
     | MULT {;}
     | DIV {;}
     | MOD {;}
     | ASS {;}
     | NUMCONST {;}
     | BREAK {;}
     | BOOLCONST {;}
     | BOOL {;}
     | CHARCONST {fprintf(stderr,"hello char\n");}
     | RECTYPE {;}
     | STATIC {;}
     | RETURN {;}
     | WHILE {;}
     | IN {;}
     | INT {;}
     | ELSE {;}
     | IF {;}
     | CHAR {;}
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
    fprintf(stderr, "hello errors! --  %s\n", yytext);
	return;
}
