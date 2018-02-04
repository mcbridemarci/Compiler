//System library imports
#include<stdio.h>
#include<stdlib.h>

//AST definition import
#include "printTree.h"
#include <string.h>

//Reference line number from parser
extern int line_num;

/*
* Track indentation level for AST printing?
*/
static format = 0;
#define TAB format=2
#define UNTAB format-=2

static void spacing(void)
{
  int i;
  for (i=0; i<format; i++)
    printf("!\t");
}

//Reference parser error function
void yyerror(const char* s);

/*
* Allocate new Statement node
*/
TreeNode* newStmtNode(StmtKind kind) {

	//Allocate memory for node
	TreeNode *t = (TreeNode*) malloc(sizeof(TreeNode));

	//Check for allocation success
	if(t == NULL)
		yyerror("Failure to allocate STMT node\n");

	//Initialize children to NULL
	for (int i = 0; i<MAXCHILDREN; i++)
		t->child[i] = NULL;

	//Initialize next node to NULL
	t->sibling = NULL;

	//Set node to Statement and kind
	t->nodekind = StmtK;
	t->kind.stmt = kind;

	//Set line number to parser line count
	t->lineno = line_num;

	//Zero out flags
	t->isArray = 0;
	t->isRecord = 0;
	t->isStatic = 0;
	t->isParam = 0;
	t->isFunc = 0;

	t->size = 0;
	t->offset = 0;
	t->ref = 0;

	//Set return type to default
	t->expType = VoidT;

	//Return finished node
	return t;
}
/*
* Allocate new Expression node
*/
TreeNode* newExpNode(ExpKind kind) {

	//Allocate memory for node
	TreeNode *t = (TreeNode*) malloc(sizeof(TreeNode));

	//Check for allocation success
	if(t == NULL)
		yyerror("Failure to allocate STMT node\n");

	//Initialize children to NULL
	for (int i = 0; i<MAXCHILDREN; i++)
		t->child[i] = NULL;

	//Initialize next node to NULL
	t->sibling = NULL;

	//Set node to Statement and kind
	t->nodekind = ExpK;
	t->kind.exp = kind;

	//Set line number to parser line count
	t->lineno = line_num;

	//Zero out flags
	t->isArray = 0;
	t->isRecord = 0;
	t->isStatic = 0;
	t->isParam = 0;
	t->isFunc = 0;

	t->size = 0;
	t->offset = 0;
	t->ref = 0;

	//Set return type to default
	t->expType = VoidT;

	//Return finished node
	return t;
}

/*
* Allocate new Declaration node
*/
TreeNode* newDeclNode(DeclKind kind) {

	//Allocate memory for node
	TreeNode *t = (TreeNode*) malloc(sizeof(TreeNode));

	//Check for allocation success
	if(t == NULL)
		yyerror("Failure to allocate STMT node\n");

	//Initialize children to NULL
	for (int i = 0; i<MAXCHILDREN; i++)
		t->child[i] = NULL;

	//Initialize next node to NULL
	t->sibling = NULL;

	//Set node to Statement and kind
	t->nodekind = DeclK;
	t->kind.decl = kind;

	//Set line number to parser line count
	t->lineno = line_num;

	//Zero out flags
	t->isArray = 0;
	t->isRecord = 0;
	t->isStatic = 0;
	t->isParam = 0;
	t->isFunc = 0;

	t->size = 0;
	t->offset = 0;
	t->ref = 0;

	//Set return type to default
	t->expType = VoidT;

	//Return finished node
	return t;
}
/*
 * Print a token
 */ 
void printOp(TokenClass token) {
    
    switch (token) {
        case PLUS: 
            printf("Op: + "); break;
        case INC:
            printf("Op: ++ "); break;
        case DASH:
            printf("Op: - "); break;
        case DEC:
            printf("Op: -- "); break;
        case ASSIGN:
            printf("Assign: = "); 
        case ADDASS:
            printf("Op: += "); break;
        case SUBASS:
            printf("Op: -= "); break;
        case MULASS:
            printf("Op: *= "); break;
        case DIVASS:
            printf("Op: /= "); break;
        case ASTERISK:
            printf("Op: * "); break;
        case FSLASH:
            printf("Op: / "); break;
        case NOT:
            printf("Op: not "); break;
        case AND:
            printf("Op: and "); break;
        case OR:
            printf("Op: or "); break;
        case EQ:
            printf("Op: == "); break;
        case NOTEQ:
            printf("Op: != "); break;
        case LESSEQ:
            printf("Op: <= "); break;
        case LTHAN:
            printf("Op: < "); break;
        case GRTEQ:
            printf("Op: >= "); break;
        case GTHAN:
            printf("Op: > "); break;
        case RANDOM:
            printf("Op: ? "); break;
        case MOD:
            printf("Op: % "); break;
        case LSQB:
            printf("Op: [ "); break;
        case PERIOD:
            printf("Op: . "); break;
        case COLON:
            printf("Op: : "); break;
        default: /* should never happen */
            printf("Unknown token %d\n", token);
    }
}

/*
* Print the AST
*/
void printTree(FILE* output, TreeNode* tree) {
 
	//Check if we exist before printing
	while (tree != NULL)
	{
    TAB
    spacing();
		//Statement node printing
		if (tree->nodekind == StmtK)
		{
			switch (tree->kind.stmt)
			{
       case Ifk:
        prinf("If [line: %d]\n", lineno);
        break;
       case WhileK:
        prinf("While [line: %d]\n", lineno);
        break;
       case ReturnK:
        prinf("Return [line: %d]\n", lineno);
        break;
       case BreakK:
        prinf("Break [line: %d]\n", lineno);
        break;
       case CompoundK:
        prinf("Compound [line: %d]\n", lineno);
        break;
       default: 
        prinf("Whoops, unrecognized expression.\n");
        break;
			}
		}
		//Expression node printing
		else if (tree->nodekind == Expk)
		{
			switch (tree->kind.exp)
			{
        case Opk:
          printOp(tree->attr.op);
          printf("[line: %d]\n", lineno);
          break;
        case ConstK:
          printf("Const: %d [line: %d]\n", tree->attr.val, lineno);
          break;
        case IdK:
          printf("Id: %s [line: %d]\n", tree->attr.name, lineno);
          break;
        default: 
          prinf("Whoops, unrecognized expression.\n");
          break;
			}
		}

		//Declaration node printing
		else if (tree->nodekind == Declk)
		{
			switch (tree->kind.decl)
			{
        case VarK:
          prinf("Var %s of type %s [line: %d]\n", tree->attr.name, expType, lineno);
          break;
        case FuncK:
          printf("Func %s returns type %s [line: %d]\n", tree->attr.name, expType, lineno);
          break;
        case RecK:
          printf("Return [line: %d]\n", lineno);
          break;
        default: 
          prinf("Whoops, unrecognized declaration.\n");
          break;
			}
		}
		
		else
			yyerror("Unknown node");

//Print kids after we finish
		for (int i = 0; i < MAXCHILDREN; i++)
		{
			if(tree->child[i] != NULL)
			{
				printTree(tree->child[i]);
			}
      else
        tree->child[0] = NULL
		}

		//Point to the next node in the AST
		tree = tree->sibling;
	}
	//END WHILE
  UNTAB;

	return;
}
