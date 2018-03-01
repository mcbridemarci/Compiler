%{
//Custom dinner with added features! :D
//Should work on printing maybe?
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
%token <sval> ALLERGEN
%token <sval> CHEMICAL

//Literal tokens
%token DINNER TYPE
%token END ENDL
%token SPECIALS
%token CHEMICALS

%%

dinner:
	header template specials body_section chemistry footer {
	printf("\nDone with the dinner menu!\n"); }
	;

header:
	DINNER FLOAT ENDLS {
	printf("Reading a diNNeR menu version %f\n",$2); }
	;

template:
	typelines
	;

typelines:
	typelines typeline
	| typeline
	;

typeline:
	TYPE STRING ENDLS {
	printf("New defined dinner type: %s\n",$2); }
	;

specials:
	SPECIALS ENDLS {
	printf("\nThe specials tonight are as follows:\n"); }
	;

body_section:
	body_lines
	;

body_lines:
	body_lines body_line
	| body_line
	;

body_line:
	INT INT INT INT STRING allergens ENDLS {
	printf("Dinner offered: %d%d%d%d%s.\n", $1,$2,$3,$4,$5); }
	;

chemistry:
    CHEMICALS ENDL kemikals
    ;

kemikals:
    kemikals kemikal
    | kemikal
    ;

kemikal:
    chems ENDLS
    ;

chems:
    chems chem
    | chem
    ;

chem:
    CHEMICAL {
    printf("\nchemical %s is in the dinner", $1); }
    ;

footer:
	END ENDLS
	| END
	;

ENDLS:
	ENDLS ENDL
	| ENDL
	;

allergens:
    allergens allergy
    | allergy
    ;

allergy:
    ALLERGEN {
    printf("Beware of %s in this dinner.\n", $1); }
    ;

%%

int main(int argc, char** argv) {

	//Open file handle to read input
	FILE* myfile = fopen("menu.dinner","r");

	//Check if input file opened
	if(!myfile) {

		printf("Excuse me, I can't read the menu!\n");
		return(-1);
	}

	//Tell bison to read from file stream
	yyin = myfile;

	//Parse the input
	do{
		yyparse();
	}while(!feof(yyin));
}

void yyerror(const char* s) {

	//An error has occurred
	printf("I want to speak to the manager on line %d! - Parser error: %s\n",line_num, s);
	//Might as well quit
	exit(-1);
	return;
}
