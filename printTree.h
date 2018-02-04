#ifndef _printtree_H_
#define _printtree_H_

#define MAXCHILDREN 3

/*
* Main kind of Tree Node
*
* Declaration node
* Statement node
* Expression node
*/
typedef enum {
    StmtK,
    ExpK,
    DeclK
} NodeKind;


/*
* Kinds of declarations
*
* Variable declaration
* Function declaration
* Record declaration
*/
typedef enum {
    VarK,
    FuncK,
    RecK
} DeclKind;

/*
* Kinds of statements
*
* If statement
* While statement
* Return statement
* Break statement
* Compound statement
*/
typedef enum {
    IfK,
    WhileK,
    ReturnK,
    BreakK,
    CompundK
} StmtKind;

/*
* Kinds of expressions
*
* Operation expression
* Constant expression
* ID expression
*/
typedef enum {
    OpK,
    ConstK,
    IdK
} ExpKind;

/*
* Expression return type
*
* Void - Default
* Number
* True/False
* Single character
*/
typedef enum {
    VoidT,
    NumT,
    BoolT,
    CharT
} ExpType;

/*
* Operation token
*
* plus -     +
* pplus -   ++
* dash -     -
* ddash -   --
* assign -   =
* passign - +=
* sassign - -=
* massign - *=
* dassign - /=
* asterisk - *
* fslash -   /
* bNOT -   NOT
* bAND -   AND
* bOR -     OR
* eqeq -    ==
* neq -     !=
* lteq -    <=
* lthan -    <
* gteq -    >=
* gthan -    >
* qmark -    ?
* mod -      %
* lsb -      [
* period -   .
* colon -    :
*/
typedef enum {} OpKind;

/*
* Structure to hold AST node properties
* Essentially chained in a large linked list
* Holds essential code elements
*/
typedef struct TreeNode {

	/*
	* Pointer to child AST node array
	*/
	struct TreeNode* child[MAXCHILDREN];

	/*
	* Pointer to next AST node
	*/
	struct TreeNode* sibling;

	/*
	* Line number of AST element
	*/
	int lineno;

	/*
	* Node's main type
	*/
	NodeKind nodekind;

	/*
	* Union to hold node's subtype
	*/
	union
	{
		DeclKind decl;
		StmtKind stmt;
		ExpKind exp;
	} kind;

	/*
	* Node's main payload
	*/
	union
	{
		OpKind op;
		int value;
		unsigned char cvalue;
		char* name;
	} attr;

	/*
	* Return type of expression
	*/
	ExpType expType;

	/*
	* Holds custom type if rectype var
	*/
	char* recType;

	/*
	* Special flags
	*
	* Is an array
	* Is a record
	* Is statically declared
	* Is a function parameter
	* Is a function call
	*/
	int isArray;
	int isRecord;
	int isStatic;
	int isParam;
	int isFunc;

} TreeNode;


/*
* Print the AST
*/
void printTree(FILE* out, TreeNode* tree);

/*
* Allocate new Declaration node
*/
TreeNode* newDeclNode(DeclKind);

/*
* Allocate new Expression node
*/
TreeNode* newExpNode(ExpKind);

/*
* Allocate new Statement node
*/
TreeNode* newStmtNode(StmtKind);

#endif

