%{
#define YYPARSER

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

int j = 0;

//Reference parser error function
void yyerror(const char* s);

%}

//Use a union to hold possible grammar data types
%union {
    Token token;
    struct TreeNode* treeNode;
}

//Associate token types with union fields, terminal symbol AKA token type
%token <token> ID NUMCONST CHARCONST RECTYPE BOOLCONST RECORD
%token <token> STATIC INT BOOL CHAR IF ELSE WHILE RETURN BREAK OR AND NOT
%token <token> EQ NOTEQ MULASS INC ADDASS DEC SUBASS DIVASS LESSEQ GRTEQ
%token <token> ASTERISK RANDOM DASH FSLASH LPAREN RPAREN PLUS COMMA
%token <token> LSQB RSQB COLON SCOLON LTHAN ASSIGN GTHAN
%token <token> MOD PERIOD LCB RCB

//Types for nonterminals
%type <treeNode> program declarationList declaration recDeclaration
%type <treeNode> varDeclaration scopedVarDeclaration varDeclList
%type <treeNode> varDeclInitialize varDeclId scopedTypeSpecifier
%type <treeNode> typeSpecifier returnTypeSpecifier funDeclaration
%type <treeNode> params paramList paramTypeList paramIdList paramId
%type <treeNode> statement matched unmatched iterationHeader otherStmt
%type <treeNode> compoundStmt localDeclarations statementList 
%type <treeNode> expressionStmt returnStmt breakStmt expression
%type <treeNode> simpleExpression andExpression unaryRelExpression
%type <treeNode> relExpression relop sumExpression sumop term mulop
%type <treeNode> unaryExpression unaryop factor mutable immutable call
%type <treeNode> args argList constant


//Grammar starting point
%start program

%%
program:
    declarationList { syntaxTree = $1; }
    ;

declarationList:
    declarationList declaration {
        TreeNode* t = $1;
        if(t != NULL){
            while(t->sibling != NULL)
                t = t->sibling;

            t->sibling = $2;
            $$ = $1;
        }
        else {
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

recDeclaration:
    RECORD RECTYPE LCB localDeclarations RCB {
        TreeNode* t = newDeclNode(RecK); 
        t->isRecord = 1;
        t->attr.name = strdup($2.string);  
        t->lineno = $2.lineNumber;
  
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $4;
        $$ = t;
    }
    ;

varDeclaration:
    typeSpecifier varDeclList SCOLON {
        TreeNode* t = newDeclNode(VarK); 
	    TreeNode* i = t;
        t->expType = $1->expType;
	    i->sibling = $2;
 
        while (i->sibling != NULL) {
            i = i->sibling;
            i->kind.decl = VarK;
            i->expType = $1->expType;
        } 
        $$ = $2;
    }
    ;

scopedVarDeclaration:
    scopedTypeSpecifier varDeclList SCOLON {
        TreeNode* t = $2;
        t->expType = $1->expType;
        $$ = t; 
    }
    ;

varDeclList:
    varDeclList COMMA varDeclInitialize  {
        TreeNode* t = $1;
        if(t != NULL) {
            while(t->sibling != NULL)
                t = t->sibling;

            t->sibling = $3;
            $$ = $1;
        }
        else {
            $$ = $3;
        }
    }
    | varDeclInitialize {$$ = $1;}
    ;

varDeclInitialize:
    varDeclId {$$ = $1;}
    | varDeclId COLON simpleExpression {
        j = 0; 
        while ($1->child[j] != NULL) {
            j++;
        } 
        $1->child[j] = $3;
        $$ = $1;
        }
    ;

varDeclId:
    ID {
        TreeNode* t = newDeclNode(VarK);
        t->attr.name = $1.string;
        t->lineno = $1.lineNumber;
        $$ = t;
    }
    | ID LSQB NUMCONST RSQB {
        TreeNode* t = newDeclNode(VarK);
        t->attr.name = $1.string;
        t->lineno = $1.lineNumber;
        t->isArray = 1;
        $$ = t;
    }
    ;

scopedTypeSpecifier:
    STATIC typeSpecifier {
        $2->isStatic = 1;
        $$ = $2;
        }
    | typeSpecifier {$$ = $1;}
    ;

typeSpecifier:
    returnTypeSpecifier {$$ = $1;}
    | RECTYPE { //TODO fill in RECTYPE braces
    }   
    ;

returnTypeSpecifier:
    INT {
        TreeNode* t = newDeclNode(VarK);
        t->expType = NumT;
        $$ = t;
        }
    | BOOL {
        TreeNode* t = newDeclNode(VarK);
        t->expType = BoolT;
        $$ = t;
        }
    | CHAR {
        TreeNode* t = newDeclNode(VarK);
        t->expType = CharT;
        $$ = t;
        }
    ;

funDeclaration:
    typeSpecifier ID LPAREN params RPAREN statement {
        TreeNode* t = newDeclNode(FuncK); 
	t->attr.name = $2.string;
        t->expType = $1->expType;
        t->lineno = $2.lineNumber;
        
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $4;
	TreeNode* r = $4;
	while(r){
		printf("%s\n", $4->attr.name);
		r = r->sibling;
	}
	t->child[++j] = $6;
        $$ = t;
    }
    | ID LPAREN params RPAREN statement {
        TreeNode* t = newDeclNode(FuncK); 
	t->attr.name = $1.string;
        t->lineno = $1.lineNumber;
        
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $3;
        t->child[++j] = $5;
        $$ = t;
    }
    ;

params:
    paramList {$$ = $1;}
    | %empty {$$ = NULL;}
    ;

paramList:
    paramList SCOLON paramTypeList
    {
        TreeNode* t = $1;
        while (t->sibling != NULL) {
            t = t->sibling;
        } 
        t->sibling = $3;
        $$ = t;
    }
    | paramTypeList {$$ = $1;}
    ;

paramTypeList:
    typeSpecifier paramIdList {
        TreeNode* t = $2; 
        t->kind.decl = FuncK;
        t->expType = $1->expType;
 
        while (t->sibling != NULL) {
            t = t->sibling;
            t->kind.decl = FuncK;
            t->expType = $1->expType;
        }
	$$ = $2;
    }
    ;

paramIdList:
    paramIdList COMMA paramId {
        TreeNode* t = $1;
        if (t != NULL) {
            while(t->sibling != NULL)
                t = t->sibling;

            t->sibling = $3;
            $$ = $1;
        }
        else {
            $$ = $3;
        }
    }
    | paramId {$$ = $1;}
    ;

paramId:
    ID {
        TreeNode* t = newDeclNode(FuncK);
	t->isParam = 1;
        t->attr.name = $1.string;
        t->lineno = $1.lineNumber;
        $$ = t; 
    }
    | ID LSQB RSQB {
        TreeNode* t = newDeclNode(FuncK);
	t->isParam = 1;
        t->isArray = 1;
        t->attr.name = $1.string;
        t->lineno = $1.lineNumber;
        $$ = t;
    }
    ;

statement:
    matched {$$ = $1;}
    | unmatched {$$ = $1;}
    ;

matched:
    IF LPAREN simpleExpression RPAREN matched ELSE matched {
        TreeNode* t = newStmtNode(IfK);
        t->lineno = $1.lineNumber;

        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $3;
        t->child[++j] = $5;
        t->child[++j] = $7;
        $$ = t;
    }
    | iterationHeader matched {
        TreeNode* t = $1;  
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        }
        t->child[j] = $2;
    }
    | otherStmt {$$ = $1;}
    ;

unmatched:
    IF LPAREN simpleExpression RPAREN matched {
        TreeNode* t = newStmtNode(IfK);
        t->lineno = $1.lineNumber;

        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $3;
        t->child[++j] = $5;
        $$ = t;
    }
    | IF LPAREN simpleExpression RPAREN unmatched {
        TreeNode* t = newStmtNode(IfK);
        t->lineno = $1.lineNumber;

        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $3;
        t->child[++j] = $5;
        $$ = t;
    }
    | IF LPAREN simpleExpression RPAREN matched ELSE unmatched {
        TreeNode* t = newStmtNode(IfK);
        t->lineno = $1.lineNumber;

        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $3;
        t->child[++j] = $5;
        t->child[++j] = $7;
        $$ = t;
    }
    | iterationHeader unmatched {
        TreeNode* t = $1;  
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        }
        t->child[j] = $2;
        }
    ;

iterationHeader: 
    WHILE LPAREN simpleExpression RPAREN {
        TreeNode* t = newStmtNode(WhileK);
        t->lineno = $1.lineNumber;
        $$ = t;

        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $3;
        $$ = t;
    }
    ;

otherStmt:
    expressionStmt {$$ = $1;}
    | compoundStmt {$$ = $1;}
    | returnStmt {$$ = $1;}
    | breakStmt {$$ = $1;}
    ;

compoundStmt:
    LCB localDeclarations statementList RCB {
        TreeNode* t = newStmtNode(CompoundK);
        t->lineno = $1.lineNumber;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $2;
        t->child[++j] = $3;
        $$ = t;
        }
    ;

localDeclarations:
    localDeclarations scopedVarDeclaration {$$ = $2;} 
    | %empty {$$ = NULL;}
    ;

statementList:
    statementList statement {
        TreeNode* t = $1;
        if (t != NULL) {
            while(t->sibling != NULL)
                t = t->sibling;

            t->sibling = $2;
            $$ = $1;
        }
        else {
            $$ = $2;
        }
    }
    | %empty {$$ = NULL;}
    ;

expressionStmt:
    expression SCOLON {$$ = $1;}
    | SCOLON {$$ = NULL;}
    ;

returnStmt:
    RETURN SCOLON {
        TreeNode* t = newStmtNode(ReturnK);
        t->lineno = $1.lineNumber;
        $$ = t;
    }
    | RETURN expression SCOLON {
        TreeNode* t = newStmtNode(ReturnK);
        t->lineno = $1.lineNumber;
        $$ = t;

        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $2;
        $$ = t;
    }
    ;

breakStmt:
    BREAK SCOLON {
        TreeNode* t = newStmtNode(BreakK);
        t->lineno = $1.lineNumber;
        $$ = t;
    }
    ;


expression:
    mutable ASSIGN expression {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $2.lineNumber;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $1;
        t->child[++j] = $3;
        t->attr.op = Assign;
        $$ = t;
        }
    | mutable ADDASS expression {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $2.lineNumber;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $1;
        t->child[++j] = $3;
        t->attr.op = Addass;
        $$ = t;
        }
    | mutable SUBASS expression {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $2.lineNumber;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $1;
        t->child[++j] = $3;
        t->attr.op = Subass;
        $$ = t;
        }
    | mutable MULASS expression {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $2.lineNumber;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $1;
        t->child[++j] = $3;
        t->attr.op = Mulass;
        $$ = t;
        } 
    | mutable DIVASS expression {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $2.lineNumber;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $1;
        t->child[++j] = $3;
        t->attr.op = Divass;
        $$ = t;
        }
    | mutable INC {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $2.lineNumber;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $1;
        t->attr.op = Inc;
        $$ = t;
        } 
    | mutable DEC {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $2.lineNumber;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $1;
        t->attr.op = Dec;
        $$ = t;
        } 
    | simpleExpression {$$ = $1;}
    ;

simpleExpression:
    simpleExpression OR andExpression {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $2.lineNumber;
        t->attr.op = Or;

        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $1;
        t->child[j] = $3;
        $$ = t;
        } 
    | andExpression {$$ = $1;}
    ;

andExpression: 
    andExpression AND unaryRelExpression {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $2.lineNumber;
        t->attr.op = And;

        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        } 
        t->child[j] = $1;
        t->child[j] = $3;
        $$ = t;
        } 
    | unaryRelExpression {$$ = $1;}
    ;

unaryRelExpression:
    NOT unaryRelExpression {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Not;

        j = 0;    
        while ($2->child[j] != NULL) {
            j++;
        } 
        $2->child[j] = $2;
        $$ = t;
        } 
    | relExpression {$$ = $1;}
    ;

relExpression:
    sumExpression relop sumExpression {
        j = 0;    
        while ($2->child[j] != NULL) {
            j++;
        } 
        $2->child[j] = $1;
        $2->child[++j] = $3;
        $$ = $2;
    }
    | sumExpression {$$ = $1;}
    ;

relop:
    LESSEQ {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Lesseq;
        $$ = t;
        } 
    | GRTEQ {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Grteq;
        $$ = t;
        } 
    | GTHAN {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Gthan;
        $$ = t;
        } 
    | LTHAN {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Lthan;
        $$ = t;
        } 

    | EQ {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Eq;
        $$ = t;
        } 
    | NOTEQ { 
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Noteq;
        $$ = t;
        }
    ;

sumExpression:
    sumExpression sumop term {
        j = 0;    
        while ($2->child[j] != NULL) {
            j++;
        } 
        $2->child[j] = $1;
        $2->child[++j] = $3;
        $$ = $2;
    }
    | term {$$ = $1;}
    ;

sumop:
    PLUS { 
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Plus;
        $$ = t;
        }
    | DASH {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Dash;
        $$ = t;
        }
    ;

term:
    term mulop unaryExpression {
        j = 0;    
        while ($2->child[j] != NULL) {
            j++;
        } 
        $2->child[j] = $1;
        $2->child[++j] = $3;
        $$ = $2;
    }
    | unaryExpression {$$ = $1;}
    ;

mulop:
    ASTERISK {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Asterisk;
        $$ = t;
        }
    | FSLASH {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Fslash;
        $$ = t;
        }
    | MOD {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Mod;
        $$ = t;
        }
    ;

unaryExpression:
    unaryop unaryExpression {
        j = 0;    
        while ($2->child[j] != NULL) {
            j++;
        } 
        $2->child[j] = $2;
        $$ = $2;
    }
    | factor {$$ = $1;}
    ;

unaryop:
    DASH {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Dash;
        $$ = t;
        }
    | ASTERISK  {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Asterisk;
        $$ = t;
        }
    | RANDOM {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Random;
        $$ = t;
        }
    ;

factor:
    immutable {$$ = $1;}
    | mutable {$$ = $1;}
    ;

mutable:
    ID {
        TreeNode* t = newExpNode(IdK);
        t->attr.name = $1.string;
        t->lineno = $1.lineNumber;
        $$ = t;
    }
    | mutable LSQB expression RSQB {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $2.lineNumber;
        t->attr.op = Lsqb;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        }
        t->child[j] = $1; 
        t->child[++j] = $3;
        $$ = t;
        }
    | mutable PERIOD ID {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $2.lineNumber;
        t->attr.op = Period;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        }

        t->child[j] = $1;

        TreeNode* s = newExpNode(IdK);
        s->attr.name = $3.string;
        s->lineno = $3.lineNumber;
        t->child[++j] = s;

        $$ = t;
        }
    | LSQB expression RSQB {
        TreeNode* t = newExpNode(OpK);
        t->lineno = $1.lineNumber;
        t->attr.op = Lsqb;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        }
        t->child[j] = $2; 
        $$ = t;
        }
    ;

immutable:
    LPAREN expression RPAREN {$$ = $2;}
    | call {$$ = $1;}
    | constant {$$ = $1;}
    ;

call:
    ID LPAREN args RPAREN {
        TreeNode* t = newExpNode(IdK);
        t->lineno = $1.lineNumber;
        t->attr.name = $1.string;
        j = 0;    
        while (t->child[j] != NULL) {
            j++;
        }

        t->child[j] = $3;
        $$ = t;
        }
    ;

args:
    argList {$$ = $1;}
    | %empty {$$ = NULL;}
    ;

argList: 
    argList COMMA expression  {
        TreeNode* t = $1;
        if (t != NULL) {
            while(t->sibling != NULL)
                t = t->sibling;

            t->sibling = $3;
            $$ = $1;
        }
        else {
            $$ = $3;
        }
    }
    | expression {$$ = $1;}
    ;

constant:
    NUMCONST {
        TreeNode* t = newExpNode(ConstK);
        t->attr.value = $1.value;
        t->expType = NumT;
        $$ = t;
        }
    | CHARCONST {
        TreeNode* t = newExpNode(ConstK);
        t->attr.cvalue = $1.letter; 
        t->expType = CharT;
        $$ = t;
        }
    | BOOLCONST {
        TreeNode* t = newExpNode(ConstK);
        t->attr.value = $1.value;
        t->expType = BoolT;
        $$ = t;
        }
    ;


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
        /**
          printf ("non-option ARGV-elements: ");
          while (optind < argc){
          printf ("%s ", argv[optind++]);
          putchar ('\n');
          }
         **/
        myfile = fopen(argv[optind], "r");
        yyin = myfile;
    } else { //No file name given
        yyin = stdin;   
    }

    //Parse input until EOF
    while(!feof(yyin) && !ferror(yyin)){
        yyparse();
    }
    printf("\n\n\n\n\nout of yyparse!\n\n\n\n\n\n");
    printTree(syntaxTree);

    //Close read-in file
    printf("\n\n\n\n\nout of printTree!\n\n\n\n\n\n");
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
