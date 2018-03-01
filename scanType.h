#ifndef _SCANTYPE_H_
#define _SCANTYPE_H_


/*
* Main kind of token type
*
* ID token
* Number token
* Character token
* Record token
* Boolean token
* Keyword token
*/
/*typedef enum {
	NUMBER = 1,
	CHARACTER = 2,
	RECORD = 3,
	BOOLEAN = 4,
	KEYWORD = 5,
    ID = 6
} TokenClass;*/


/*
* Structure to hold Token data
*/
typedef struct {

	//Token type to differentiate tokens
	int type;
	//Token location in code
	int line_num;
	//Token raw string from code
	char *raw_str;
	//Token single character value
	char c;
	//Token numerical value of the str
	int num; 
} Token;

/*
* Linked list of RECTYPEs
* Allows us to maintain list of custom types
*/
typedef struct RType {

	//Record type name
	char* rtype;

	//Pointer to another record type
	struct RType* next;

} RType;

/*
* Function to allocate character constant token
*
* line - Token line number
* ltr - Character value
* str - User supplied string character was found in
*/
Token* newCHARtoken(int line, char ltr, char* str);

/*
* Function to allocate ID token
*
* line - Token line number
* str - User supplied string ID was found in
*/
Token* newIDtoken(int line, char* str);

/*
* Function to allocate character constant token
*
* line - Token line number
* str - User supplied string record was found in
*/
Token* newRECtoken(int line, char* str);

/*
* Function to allocate keyword token
*
* line - Token line number
* str - User supplied string keyword was found in
*/
Token* newKEYtoken(int line, char* str);

/*
* Function to allocate numerical constant token
*
* line - Token line number
* str - User supplied string number was found in
* val - Numerical value
*/
Token* newNUMtoken(int line, char* str, int val);

/*
* Function to allocate boolean constant token
*
* line - Token line number
* str - User supplied string boolean was found in
* val - Numerical value
*/
Token* newBOOLtoken(int line, char* str, int val);

/*
* Convert string to upper case
*
* s - lowercase string
*/
void strupr(char* s);

/*
* Create rectype linked list
*
* Returns new linked list for rectypes
*/
RType* newRType(void);

/*
* Add rectype to list
*
* r - Rectype list
* s - New rectype
*/
void addRType(RType* r, char* s);

#endif

