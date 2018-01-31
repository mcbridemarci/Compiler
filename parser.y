%{
#define YYPARSER

//System library import
#include<stdio.h>
//GETOPT library
#include<string.h>

//User defined structures
//#include "scanType.h"
//#include "printTree.h"

//Enable detailed error messages
#define YYERROR_VERBOSE 1

//Inform bison about flex things
extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern int line_num;

//Main AST to parse into
//static TreeNode* syntaxTree;

//Reference parser error function
void yyerror(const char* s);

%}

//Use a union to hold possible grammar data types
%union {
	Token token;
	//struct TreeNode* treeNode;
}

//Associate token types with union fields
%token <token> ID NUMCONST CHARCONST RECTYPE BOOLCONST RECORD
%token <token> STATIC INT BOOL CHAR IF ELSE WHILE RETURN BREAK OR AND NOT
%token <token> EQ NOTEQ MULASS INC ADDASS DEC SUBASS DIVASS LESSEQ GRTEQ
%token <token> ASTERISK RANDOM DASH FSLASH LPAREN RPAREN PLUS COMMA
%token <token> LSQB RSQB COLON SCOLON LTHAN ASSIGN GTHAN
%token <token> MOD PERIOD LCB RCB

//Types for nonterminals
/* %type <treeNode> program declarationList ...
*/

//Grammar starting point
%start program

%%
/*  STUFF FOR TREE 
program:
	declarationList { syntaxTree = $1; }
	;

declarationList:
	declarationList declaration
	{

 //Good idea code for left recursion to link together lists
 //No malloc here because the list members should already exist, yeah?
		TreeNode* t = $1;

		if(t != NULL)
		{
			while(t->sibling != NULL)
				t = t->sibling;

			t->sibling = $2;
			$$ = $1;
		}
		else
	{
			$$ = $2;
		}
	}
	| %empty { $$ = NULL; }
	;

declaration:
//Just passing stuff up the stack
	varDeclaration { $$ = $1; }
	| funDeclaration { $$ = $1; }
	| recDeclaration { $$ = $1; }
	;

constant:
	NUMCONST
	{
//This is where/how list members come from/in
		TreeNode* t = newExpNode(ConstK);

		t->attr.value = $1.value;
		t->expType = Integer;

		$$ = t;
	}
	;
    */
// Grammer we created 
program:
       declarationList
       ;

declarationList:
               declarationList declaration 
               | declaration
               ;

declaration:
           varDeclaration
           | funDeclaration
           | recDeclaration
           ;

recDeclaration: RECORD ID LCB localDeclarations RCB
              ;

varDeclaration:
              typeSpecifier varDeclList SCOLON
              ;

scopedVarDeclaration:
                    scopedTypeSpecifier varDeclList SCOLON
                    ;

varDeclList:
           varDeclList COMMA varDeclInitialize 
           | varDeclInitialize
           ;

varDeclInitialize:
                 varDeclId 
                 | varDeclId COLON simpleExpression
                 ;

varDeclId:
         ID 
         | ID LSQB NUMCONST RCB
         ;

scopedTypeSpecifier:
                   STATIC typeSpecifier 
                   | typeSpecifier
                   ;

typeSpecifier:
             returnTypeSpecifier 
             | RECTYPE
             ;

returnTypeSpecifier:
                   INT 
                   | BOOL 
                   | CHAR
                   ;

funDeclaration:
              typeSpecifier ID LPAREN params RPAREN statement
              | ID LPAREN params RPAREN statement
              ;

params:
      paramList
      | %empty
      ;

paramList:
         paramList SCOLON paramTypeList 
         | paramTypeList
         ;

paramTypeList:
             typeSpecifier paramIdList
             ;

paramIdList:
           paramIdList COMMA paramId 
           | paramId
           ;

paramId:
       ID 
       | ID LSQB RSQB
       ;

statement:
         matched
         | unmatched
         ;

matched:
        IF matched ELSE matched
        | otherStmt
        ;
    
otherStmt:
         expressionStmt 
         | compoundStmt 
         | iterationStmt 
         | returnStmt
         | breakStmt
         ;

unmatched:
        IF unmatched
        | IF matched
        | IF matched ELSE unmatched
        ;

compoundStmt:
            LCB localDeclarations statementList RCB
            ;

localDeclarations:
                 localDeclarations scopedVarDeclaration 
                 | %empty
                 ;

statementList:
             statementList statement 
             | %empty
             ;

expressionStmt:
              expression SCOLON 
              | SCOLON
              ;

iterationStmt:
	WHILE LPAREN simpleExpression RPAREN statement
	;

returnStmt:
	RETURN SCOLON
	| RETURN expression SCOLON
	;

breakStmt:
	BREAK SCOLON


expression:
	mutable PLUS expression
	| mutable ADDASS expression
	| mutable SUBASS expression
	| mutable MULASS expression
	| mutable DIVASS expression
	| mutable INC
	| mutable DEC
	| simpleExpression
	;

simpleExpression:
	simpleExpression OR andExpression
	| andExpression
	;

andExpression: 
	andExpression AND unaryRelExpression
	| unaryRelExpression
	;

unaryRelExpression:
	NOT unaryRelExpression
	| relExpression
	;

relExpression:
	sumExpression relop sumExpression
	| sumExpression;

relop:
    LESSEQ
	| LTHAN
	| GTHAN
	| GRTEQ
	| ASSIGN
	| NOTEQ
	;

sumExpression:
	sumExpression sumop term
	| term
	;

sumop:
	PLUS
	| DASH
	;

term:
	term mulop unaryExpression
	| unaryExpression
	;

mulop:
	ASTERISK
	| FSLASH
	| MOD
	;

unaryExpression:
	unaryop unaryExpression
	| factor
	;

unaryop:
	DASH
	| ASTERISK
	| RANDOM
	;

factor:
	immutable
	| mutable
	;

mutable:
	ID
	| mutable LSQB expression RSQB
	| mutable PERIOD ID
	| LSQB expression RSQB
	;

immutable:
	LPAREN expression RPAREN
	| call
	| constant
	;

call:
	ID LPAREN args RPAREN
	;

args:
	argList
	| %empty
	;

argList: 
	argList COMMA expression
	| expression
	;

constant:
	NUMCONST
	| CHARCONST
    ;
	/*| TRUE
	| FALSE*/

%%

/*
* MAIN FUNCTION
*/


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



/*
* Parser error function
*
* s - String to include in error function
*/
void yyerror(const char* s) {

	fprintf(stdout, "ERROR(%d): %s\n",line_num, s);

	return;
}
