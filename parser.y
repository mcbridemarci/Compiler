%{
#define YYPARSER
#define YYDEBUG 0

//System library import
#include<stdio.h>
#include<getopt.h>
#include<string.h>

//User defined structures
#include "scanType.h"
#include "printTree.h"

//Enable detailed error messages
#define YYERROR_VERBOSE 1

//Inform bison about flex things
extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern int line_num;
extern int yydebug;

//Main AST to parse into
static TreeNode* syntaxTree;

//Reference parser error function
void yyerror(const char* s);

%}

//Use a union to hold possible grammar data types
%union {
	Token token;
	struct TreeNode* treeNode;
}

//Associate token types with union fields
%token <token> ID NUMCONST CHARCONST RECTYPE BOOLCONST RECORD
%token <token> STATIC INT BOOL CHAR IF ELSE WHILE RETURN BREAK OR AND NOT
%token <token> EQ NOTEQ MULASS INC ADDASS DEC SUBASS DIVASS LESSEQ GRTEQ
%token <token> ASTERISK RANDOM DASH FSLASH LPAREN RPAREN PLUS COMMA
%token <token> LSQB RSQB COLON SCOLON LTHAN ASSIGN GTHAN
%token <token> MOD PERIOD LCB RCB

//Types for nonterminals
%type <treeNode> program declarationList ...


//Grammar starting point
%start program

%%
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

recDeclaration:
              RECORD RECTYPE LCB localDeclarations RCB
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

matched:
        IF LPAREN simpleExpression RPAREN matched ELSE matched 
        | iterationHeader matched
        | otherStmt
        ;

unmatched:
         IF LPAREN simpleExpression RPAREN matched
         | IF LPAREN simpleExpression RPAREN unmatched 
         | IF LPAREN simpleExpression RPAREN matched ELSE unmatched 
         | iterationHeader unmatched
        ;

iterationHeader: 
        WHILE LPAREN simpleExpression RPAREN 
        ;

otherStmt:
         expressionStmt 
         | compoundStmt 
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
              expression SCOLON
              | SCOLON 
              ;

returnStmt:
	RETURN SCOLON
	| RETURN expression SCOLON
	;

breakStmt:
	BREAK SCOLON
    ;


expression:
    mutable ASSIGN {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
        t->nodekind = EXP;
		t->kind.exp = OPK;
        t->attr.op = ASSIGN;
		$$ = t;
        } expression 
	| mutable ADDASS {
		TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
        t->nodekind = EXP;
		t->kind.exp = OPK;
        t->attr.op = ADDASS;
		$$ = t;
        } expression
	| mutable SUBASS {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
        t->nodekind = EXP;
		t->kind.exp = OPK;
        t->attr.op = ASSIGN;
		$$ = t;
        } expression
	| mutable MULASS {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		
        //t->kind = ;
        t->attr.op = $2;
		$$ = t;
        } expression
	| mutable DIVASS {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		
        //t->kind = ;
        t->attr.op = $2;
		$$ = t;
        } expression
	| mutable INC {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		
        //t->kind = ;
        t->attr.op = $2;
		$$ = t;
        }
	| mutable DEC {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		
        //t->kind = ;
        t->attr.op = $2;
		$$ = t;
        }
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
	| sumExpression  
    ;

relop:
    LESSEQ 
	| GRTEQ 
	| GTHAN {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		//t->kind = ;
        t->attr.op = $1;
		$$ = t;
        }
	| LTHAN {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		//t->kind = ;
        t->attr.op = $1;
		$$ = t;
        }

	| EQ {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		//t->kind = ;
        t->attr.op = $1;
		$$ = t;
        }
	;

sumExpression:
	sumExpression sumop term 
	| term 
	;

sumop:
	PLUS { 
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		//t->kind = ;
        t->attr.op = $1;
		$$ = t;
        }
	| DASH {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		//t->kind = ;
        t->attr.op = $1;
		$$ = t;
        }
	;

term:
	term mulop unaryExpression
	| unaryExpression
	;

mulop:
	ASTERISK {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		//t->kind = ;
        t->attr.op = $1;
		$$ = t;
        }

	| FSLASH {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		//t->kind = ;
        t->attr.op = $1;
		$$ = t;
        }

	| MOD {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		//t->kind = ;
        t->attr.op = $1;
		$$ = t;
        }
	;

unaryExpression:
	unaryop unaryExpression
	| factor
	;

unaryop:
	DASH {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		//t->kind = ;
        t->attr.op = $1;
		$$ = t;
        }
	| ASTERISK  {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		//t->kind = ;
        t->attr.op = $1;
		$$ = t;
        }
	| RANDOM {
        TreeNode* t = newExpNode(ConstK);
        t->lineno = linenum;
		//t->kind = ;
        t->attr.op = $1;
		$$ = t;
        }
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
