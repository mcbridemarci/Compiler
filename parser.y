%{
#define YYPARSER
#define YYDEBUG 0

//System library import
#include<stdio.h>
#include<getopt.h>
#include<string.h>

//User defined structures
#include "scanType.h"
//#include "printTree.h"

//Enable detailed error messages
#define YYERROR_VERBOSE 1

//Inform bison about flex things
extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern int line_num;
extern int yydebug;

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

//added second line
recDeclaration:
              RECORD ID LCB localDeclarations RCB {printf("found a record! YAYA!!\n");}
              | RECORD RECTYPE LCB localDeclarations RCB {printf("found a record! YAYA!!\n");}
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
         | ID LSQB NUMCONST RSQB
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

/* Shift reduce conflict could be from
        IF LPAREN expressionStmt RPAREN matched ELSE matched
        conflicting with
        IF LPAREN expressionStmt RPAREN matched

        also maybe from
        IF LPAREN expressionStmt RPAREN matched
        conflicting with
        IF LPAREN expressionStmt RPAREN matched ELSE unmatched
*/

//Still need to fix this!
matched:
        otherStmt
        | IF LPAREN expression RPAREN matched ELSE matched {printf("found a matched IF ELSE @ line %d\n", line_num);}
        ;

unmatched:
         IF LPAREN expression RPAREN matched {printf("found an IF IF ELSE or lonely if @ line %d\n", line_num);}
         | IF LPAREN expression RPAREN unmatched {printf("found an IF with stuff after it @ line %d\n", line_num);}
        //| IF LPAREN expression RPAREN matched ELSE unmatched {printf("\n\n\nIF MATCHED ELSE UNMATCHED\n\n\n\n");} //Do we really need this part??
        ;

otherStmt:
         expressionStmt 
         | compoundStmt 
         | iterationStmt 
         | returnStmt
         | breakStmt
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
              expression SCOLON //{printf("found an expressionSTMT @ line %d\n", line_num); }
              | SCOLON //{printf("found an expressionSTMT @ line %d\n", line_num); }
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
    ;


expression:
    mutable ASSIGN expression //{printf("found an = expression @ line %d\n", line_num); }
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
	andExpression AND unaryRelExpression //{printf("found an and expression @ line %d\n", line_num); }
	| unaryRelExpression //{printf("found an and expression (UNARY REL) @ line %d\n", line_num); }
	;

unaryRelExpression:
	NOT unaryRelExpression  //{printf("found a NOT unaryRelExp @ line %d\n", line_num); }
	| relExpression  //{printf("found a unaryRelExp @ line %d\n", line_num); }
	;

relExpression:
	sumExpression relop sumExpression  //{printf("found a RelExp with RELOP @ line %d\n", line_num); }
	| sumExpression  //{printf("found a RelExp without RELOP @ line %d\n", line_num); }
    ;

relop:
    LESSEQ {printf("found a <= relop @ line %d\n", line_num); }
	| GRTEQ {printf("found a >= relop @ line %d\n", line_num); }
	| GTHAN {printf("found a > relop @ line %d\n", line_num); }
	| LTHAN {printf("found a < relop @ line %d\n", line_num); }
	| NOTEQ {printf("found a != relop @ line %d\n", line_num); }
	| EQ {printf("found a == relop @ line %d\n", line_num); }
	;

sumExpression:
	sumExpression sumop term //{printf("found a sumExp with TERM @ line %d\n", line_num); }
	| term //{printf("found a TERM @ line %d\n", line_num); }
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
	ID  {printf("found an ID @ line %d\n", line_num); }
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
    | BOOLCONST
    ;

	/*| TRUE
	| FALSE*/

%%

/*
* MAIN FUNCTION
*/
int main(int argc, char* argv[]) {

	/* Command line option variables
	 *
	 * c - value of flag
	 * long_options - array of word-sized options
	 * option_index - location in arg list
	 */
	int c;
	struct option long_options[] = {};
	int option_index = 0;
        FILE* myfile;

        //TODO ask TA about the weird g**********g function 
	//Check for command line args
	while ((c = getopt_long(argc, argv, "d", long_options, &option_index)) != -1){
		/*
		* The string "" arg should contain all acceptable options
                * */
		switch(c)
		{
		        //Long option present
		        case 0:
				break;
			//Debug parser
			case  'd':
				yydebug = 1;
				break;
			//Unknown option
			default:
				return(-1);
				break;
		}
	}

	//File name has also been provided
        if(option_index < argc){
            printf ("non-option ARGV-elements: ");
            while (optind < argc){
                printf ("%s ", argv[optind++]);
                putchar ('\n');
            }
            myfile = fopen(argv[optind], "r");
        } else { //No file name given
            yyin = stdin;   
	}

	//Parse input until EOF
        while(!feof(yyin)){
            yyparse();
        }

	printTree(stdout, syntaxTree);

	//Close read-in file
	fclose(yyin);

	return(0);
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