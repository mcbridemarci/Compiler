#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "scanType.h"
#include "parser.tab.h"

//Header import


//Reference parser error function
void yyerror(const char* s);

/*
* Function to allocate character constant token
*
* line - Token line number
* ltr - Character value
* str - User supplied string character was found in
*/
Token* newCHARtoken(int line, char ltr, char* str) {

	//Allocate memory for token
	Token* t = malloc(sizeof(Token));

	//Check for allocation success
	if(t == NULL)
		yyerror("Failure to allocate CHAR token\n");

	//Set line number to code line count
	t->line_num = line;
	//Set letter value to encountered char
	t->c = ltr;
	//Duplicate user-supplied string
	t->raw_str = str;
	//Set token type to character token
	t->type = CHARACTER;
	//Return token
	return t;
}

/*
* Function to allocate ID token
*
* line - Token line number
* str - User supplied string ID was found in
*/
Token* newIDtoken(int line, char* str) {

	Token* t = malloc(sizeof(Token));

	//Check for allocation success
	if(t == NULL)
		yyerror("Failure to allocate ID token\n");

	//Set line number to code line count
	t->line_num = line;
	//Set letter value to encountered char
	//Dupilicate user-supplied string
	t->raw_str = str;
	//Set token type to character token
	t->type = ID;
	//Return token
	return t;

}

/*
* Function to allocate character constant token
*
* line - Token line number
* str - User supplied string record was found in
*/
Token* newRECtoken(int line, char* str) {


	Token* t = malloc(sizeof(Token));

	//Check for allocation success
	if(t == NULL)
		yyerror("Failure to allocate REC token\n");

	//Set line number to code line count
	t->line_num = line;
	//Set letter value to encountered char
	//Duplicate user-supplied string
	t->raw_str = str;
	//Set token type to character token
	t->type = RECORD;
	//Return token
	return t;

}

/*
* Function to allocate keyword token
*
* line - Token line number
* str - User supplied string keyword was found in
*/
Token* newKEYtoken(int line, char* str) {

	Token* t = malloc(sizeof(Token));

	//Check for allocation success
	if(t == NULL)
		yyerror("Failure to allocate KEY token\n");

	//Set line number to code line count
	t->line_num = line;
	//Set letter value to encountered char
	//Duplicate user-supplied string
	t->raw_str = str;
	//Set token type to character token
	t->type = KEYWORD;
	//Return token
	return t;
}

/*
* Function to allocate numerical constant token
*
* line - Token line number
* str - User supplied string number was found in
* val - Numerical value
*/
Token* newNUMtoken(int line, char* str, int val) {

	Token* t = malloc(sizeof(Token));

	//Check for allocation success
	if(t == NULL)
		yyerror("Failure to allocate NUM token\n");

	//Set line number to code line count
	t->line_num = line;
	//Set letter value to encountered char
	//Duplicate user-supplied string
	t->raw_str = str;
	//Set token type to character token
	t->type = NUMBER;
	t->num = val;
	//Return token
	return t;
}

/*
* Function to allocate boolean constant token
*
* line - Token line number
* str - User supplied string boolean was found in
* val - Numerical value
*/
Token* newBOOLtoken(int line, char* str, int val) {

	//Store boolean value represented by val

	Token* t = malloc(sizeof(Token));

	//Check for allocation success
	if(t == NULL)
		yyerror("Failure to allocate BOOL token\n");

	//Set line number to code line count
	t->line_num = line;
	//Set letter value to encountered char
	//Duplicate user-supplied string
	t->raw_str = str;
	//Set token type to character token
	t->type = BOOLEAN;
	t->num = val;
	//Return token
	return t;
}

/*
* Convert string to upper case
*
* s - lowercase string
*/
void strupr(char* s) {

	int i = 0;

	//Until the end of the string
	while(s[i] != '\0')
	{
		//Capitalize the character
		s[i] = toupper((unsigned char)s[i]);
		i++;
	}

	return;
}

/*
* Create rectype linked list
*
* Returns new linked list for rectypes
*/
RType* newRType(void) {

	//Allocate memory for rectype list
	RType* r = malloc(sizeof(RType));

	//Check for allocation success
	if(r == NULL)
		yyerror("Failure to allocate RType list\n");

	//Set next pointer to NULL
	r->next = NULL;

	//Return list
	return r;
}

/*
* Add rectype to list
*
* r - Rectype list
* s - New rectype
*/
void addRType(RType* r, char* s) {

	//Point to list head
	RType* i = r;

	//Look for end of the list
	while(i->next != NULL)
		i = i->next;

	//Set last list member to new rectype
	i->rtype = strdup(s);

	//Add empty member to end of list
	i->next = newRType();
}

