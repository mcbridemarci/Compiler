%{
//Import input/output functions
#include<stdio.h>
//Import exit functionality
#include<stdlib.h>

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
	int ival;
	float fval;
	char* sval;
}

//Associate value tokens with union fields
%token <ival> INT
%token <fval> FLOAT
%token <sval> STRING

//Literal tokens
%token DINNER TYPE
%token END ENDL

%%

progam:
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
     | EQ
     | NUMCONST
     | ID
     | BOOLCONST
     ;

%%

int main(int argc, char** argv) {

	//Open file handle to read input
	FILE* myfile;

        if (argc > 1){
            myfile = fopen("menu.dinner", "r");
	    if(!myfile) {
                printf("Excuse me, I can't read the menu!\n");
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
