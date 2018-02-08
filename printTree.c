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
static int format = 0;
#define TAB format =2
#define UNTAB format -=2

static void spacing(void)
{
  int i;
  for (i=0; i<format; i++)
    printf("!   ");
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
    int i;
	for (i = 0; i<MAXCHILDREN; i++)
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
	/*
	t->size = 0;
	t->offset = 0;
	t->ref = 0;
	*/

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
    int i;
	for (i = 0; i<MAXCHILDREN; i++)
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
	/*
	t->size = 0;
	t->offset = 0;
	t->ref = 0;
	*/

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
    int i;
	for (i = 0; i<MAXCHILDREN; i++)
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
	/*
	t->size = 0;
	t->offset = 0;
	t->ref = 0;
	*/

	//Set return type to default
	t->expType = VoidT;

	//Return finished node
	return t;
}
/*
 * Print a token
 */ 
void printOp(OpKind token) {
    
    switch (token) {
        case Plus: 
            printf("Op: + "); break;
        case Inc:
            printf("Op: ++ "); break;
        case Dash:
            printf("Op: - "); break;
        case Dec:
            printf("Op: -- "); break;
        case Assign:
            printf("Assign: = "); break; 
        case Addass:
            printf("Op: += "); break;
        case Subass:
            printf("Op: -= "); break;
        case Mulass:
            printf("Op: *= "); break;
        case Divass:
            printf("Op: /= "); break;
        case Asterisk:
            printf("Op: * "); break;
        case Fslash:
            printf("Op: / "); break;
        case Not:
            printf("Op: not "); break;
        case And:
            printf("Op: and "); break;
        case Or:
            printf("Op: or "); break;
        case Eq:
            printf("Op: == "); break;
        case Noteq:
            printf("Op: != "); break;
        case Lesseq:
            printf("Op: <= "); break;
        case Lthan:
            printf("Op: < "); break;
        case Grteq:
            printf("Op: >= "); break;
        case Gthan:
            printf("Op: > "); break;
        case Random:
            printf("Op: ? "); break;
        case Mod:
            printf("Op: % "); break;
        case Lsqb:
            printf("Op: [ "); break;
        case Period:
            printf("Op: . "); break;
        case Colon:
            printf("Op: : "); break;
        default: /* should never happen */
            printf("Unknown token %d\n", (int)token);
    }
}

char* resolveExp(int expType) {
	char* text = "";
 	switch (expType) {
		case NumT:
			text = "int";
			return text;
		case BoolT:
			text = "bool";
			return text;
		case VoidT:
			text = "void";
			return text;
		case CharT:
			text = "char";
			return text;
		default:
			printf("Unknown ExpType\n");
	}

}

/*
* Print the AST
*/
void printTree(TreeNode* tree) {
    TAB;
    char* type;
	//Check if we exist before printing
	while (tree != NULL)
	{
    spacing();
		//Statement node printing
		if (tree->nodekind == StmtK)
		{
			switch (tree->kind.stmt)
			{
       case IfK:
        printf("If [line: %d]\n", tree->lineno);
        break;
       case WhileK:
        printf("While [line: %d]\n", tree->lineno);
        break;
       case ReturnK:
        printf("Return [line: %d]\n", tree->lineno);
        break;
       case BreakK:
        printf("Break [line: %d]\n", tree->lineno);
        break;
       case CompoundK:
        printf("Compound [line: %d]\n", tree->lineno);
        break;
       default: 
        printf("Whoops, unrecognized expression.\n");
        break;
			}
		}
		//Expression node printing
		else if (tree->nodekind == ExpK)
		{
			switch (tree->kind.exp)
			{
        case OpK:
          printOp(tree->attr.op);
          printf("[line: %d]\n", tree->lineno);
          break;
        case ConstK:
          printf("Const: %d [line: %d]\n", tree->attr.value, tree->lineno);
          break;
        case IdK:
          printf("Id: %s [line: %d]\n", tree->attr.name, tree->lineno);
          break;
        default: 
          printf("Whoops, unrecognized expression.\n");
          break;
			}
		}

		//Declaration node printing
		else if (tree->nodekind == DeclK)
		{
			switch (tree->kind.decl)
			{
        case VarK:
	  type = resolveExp(tree->expType);
	  printf("%s %s%s of type %s [line: %d]\n",
	  	tree->isParam ? "Param" : "Var", 
		tree->attr.name, 
		tree->isArray ? " is array" : "",
		type, tree->lineno
	  );
          break;
        case FuncK:
	  type = resolveExp(tree->expType);
	  printf("%s %s%s %stype %s [line: %d]\n",
	  	tree->isParam ? "Param" : "Func", 
		tree->attr.name, 
	  	tree->isParam ? " of" : " returns", 
		tree->isArray ? " is array" : "",
		type, tree->lineno
	  );
          break;
        case RecK:
          printf("Return [line: %d]\n", tree->lineno);
          break;
        default: 
          printf("Whoops, unrecognized declaration.\n");
          break;
			}
		}
		
		else
			yyerror("Unknown node");

        //Print kids after we finish
        int i;
		for (i = 0; i < MAXCHILDREN; i++)
		{
			if(tree->child[i] != NULL){
				printTree(tree->child[i]);
			}
            else
                tree->child[0] = NULL;
		}

		//Point to the next node in the AST
		tree = tree->sibling;
	}
	//END WHILE
  UNTAB;

	return;
}
