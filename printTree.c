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
#define TAB tab=2
#define UNTAB untab-=2
static level=0; 

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
* Print the AST
*/
void printTree(FILE* output, TreeNode* tree) {
 
	//Check if we exist before printing
	while (tree != NULL)
	{
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
        //TODO: finish bellow & where does Param go?!
        case VarK:
          prinf("Var %s of type %s [line: %d]\n", , , lineno);
          break;
        case FuncK:
          printf("Func %s returns type %s [line: %d]\n", lineno);
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

			//...waht if child0 doesnt exist, but other children do tho?
		}

		//Point to the next node in the AST
		tree = tree->sibling;
	}
	//END WHILE
  UNTAB;

	return;
}
//END printTREE
