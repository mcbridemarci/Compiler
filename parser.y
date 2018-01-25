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

program:
       delcarationList
       ;

declarationList:
               declaratioList declaration 
               | declaration
               ;

declaration:
           varDeclaration
           | funDeclaration
           | recDeclaration
           ;

recDeclaration: 'record' ID '{' localDeclarations '}'
              ;

varDeclaration:
              typeSpecifier varDeclList 
              ;

scopedVarDeclaration:
                    scopedTypeSpecifier varDeclList 
                    ;

varDeclList:
           varDeclList ',' varDeclInitialize 
           | varDeclInitialize
           ;

varDeclInitialize:
                 varDeclId 
                 | varDeclId : simpleExpression
                 ;

varDeclId:
         ID 
         | ID '[' NUMCONST  ']'
         ;

scopedTypeSpecifier:
                   static typeSpecifier 
                   | typeSpecifier
                   ;

typeSpecifier:
             returnTypeSpecifier 
             | RECTYPE
             ;

returnTypeSpecifier:
                   int 
                   | bool 
                   | char
                   ;

funDeclaration:
              typeSpecifier ID '(' params  ')' statement '[' ID '(' params ')' statement
              ;

params:
      paramList |
      ''
      ;

paramList:
         paramList ';' paramTypeList 
         | paramTypeList
         ;

paramTypeList:
             typeSpecifier paramIdList
             ;

paramIdList:
           paramIdList ',' paramId 
           | paramId
           ;

paramId:
       ID 
       | ID '['  ']'
       ;

statement:
         expressionStmt 
         | compoundStmt 
         | selectionStmt 
         | iterationStmt 
         | returnStmt
         | breakStmt
         ;

compoundStmt:
            '{' localDeclarations statementList '}'
            ;

localDeclarations:
                 localDeclarations scopedVarDeclaration 
                 | ''
                 ;

statementList:
             statementList statement 
             | ''
             ;

expressionStmt:
              expression ';' 
              | ';'
              ;
              
selectionStmt:
	if '(' simpleExpression ')' statement
	| if '( simpleExpression )' statement else statement
	;

iterationStmt:
	while '(' simpleExpression ')' statement
	;

returnStmt:
	return ';'
	| return expression ';'
	;

breakStmt:
	break ';'


expression:
	mutable '=' expression
	| mutable '+=' expression
	| mutable '−=' expression
	| mutable '∗=' expression
	| mutable '/=' expression
	| mutable '++'
	| mutable '−−'
	| simpleExpression
	;

simpleExpression:
	simpleExpression or andExpression
	| andExpression
	;

andExpression: 
	andExpression and unaryRelExpression
	| unaryRelExpression
	;

unaryRelExpression:
	not unaryRelExpression
	| relExpression
	;

relExpression:
	sumExpression relop sumExpression
	| sumExpression;

relop: '<='
	| '<'
	| '>'
	| '>='
	| '=='
	| '!='
	;

sumExpression:
	sumExpression sumop term
	| term
	;

sumop:
	'+'
	| '−'
	;

term:
	term mulop unaryExpression
	| unaryExpression
	;

mulop:
	∗
	| /
	| %
	;

unaryExpression:
	unaryop unaryExpression
	| factor
	;

unaryop:
	−
	| ∗
	| ?
	;

factor:
	immutable
	| mutable
	;

mutable:
	ID
	| mutable '[' expression ']'
	| mutable '.' ID
	;

immutable:
	'(' expression ')'
	| call
	| constant
	;

call:
	ID '(' args ')'
	;

args:
	argList
	| ''
	;

argList: 
	argList ',' expression
	| expression
	;

constant:
	NUMCONST
	| CHARCONST
	| true
	| false
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

	//An error has occurred
	printf("I want to speak to the manager on line %d! - Parser error: %s\n",line_num, s);
	//Might as well quit
	exit(-1);
	return;
}
