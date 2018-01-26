%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "scanType.h"                                                                          
#include "parser.tab.h"

extern int yylex();
//Count the lines
int line_num = 1;

static RType* rType;

void yyerror(const char *s);

%}

letter          [a-zA-Z]
digit           [0-9]
letdig          {letter}|{digit}
ID              {letter}+{letdig}*
NUMCONST        {digit}+
null            \0
newline         \n
CHARCONST       '[a-zA-Z0-9]|{null}|{newline}'
comments        (\/\/)+.*$
whiteSpace      [ \t\r]+

%x recname

%%
 //rules section 
comments     ; // Do nothing for comments @TODO what about new lines in comments 
           ; // Grab spaces and tabs and do nothing  
'\\n'            { yylval.token=*newCHARtoken(line_num,'\n',yytext); return CHARCONST; }
{newline}              { ++line_num; return ENDL; }
'\\0'            { yylval.token=*newCHARtoken(line_num,'\0',yytext); return CHARCONST;}

['][a-zA-Z0-9"][']       { yylval.token=*newCHARtoken(line_num,yytext[1],strdup(yytext)); return CHARCONST;}
['](\\['\\"])[']       { yylval.token=*newCHARtoken(line_num,yytext[2],strdup(yytext)); return CHARCONST;}


and             { yylval.token=*newKEYtoken(line_num,yytext); return AND; }
or              { yylval.token=*newKEYtoken(line_num,yytext); return OR; }
not             { yylval.token=*newKEYtoken(line_num,yytext); return NOT; }

"<="            { yylval.token=*newKEYtoken(line_num,yytext); return LESSEQ; }
">="            { yylval.token=*newKEYtoken(line_num,yytext); return GRTEQ; }
={2}            { yylval.token=*newKEYtoken(line_num,yytext); return EQ; }
!=              { yylval.token=*newKEYtoken(line_num,yytext); return NOTEQ; }

\+\+            { yylval.token=*newKEYtoken(line_num,yytext); return INC; }
--              { yylval.token=*newKEYtoken(line_num,yytext); return DEC; }

\+=             { yylval.token=*newKEYtoken(line_num,yytext); return ADDASS; }
-=              { yylval.token=*newKEYtoken(line_num,yytext); return SUBASS; }
\*=             { yylval.token=*newKEYtoken(line_num,yytext); return MULTASS; }
\/=             { yylval.token=*newKEYtoken(line_num,yytext); return DIVASS; }

bool            { yylval.token=*newKEYtoken(line_num,yytext); return BOOL; }
break           { yylval.token=*newKEYtoken(line_num,yytext); return BREAK; }
char            { yylval.token=*newKEYtoken(line_num,yytext); return CHAR; }
else            { yylval.token=*newKEYtoken(line_num,yytext); return ELSE; }
if              { yylval.token=*newKEYtoken(line_num,yytext); return IF; }
in              { yylval.token=*newKEYtoken(line_num,yytext); return IN; }
int             { yylval.token=*newKEYtoken(line_num,yytext); return INT; }
return          { yylval.token=*newKEYtoken(line_num,yytext); return RETURN; }
while           { yylval.token=*newKEYtoken(line_num,yytext); return WHILE; }
static          { yylval.token=*newKEYtoken(line_num,yytext); return STATIC; }
true            { yylval.token=*newBOOLtoken(line_num,yytext,1); return BOOLCONST; }
false           { yylval.token=*newBOOLtoken(line_num,yytext,0); return BOOLCONST; }
record          {
                yylval.token = *newKEYtoken(line_num,yytext);
                BEGIN(recname);
                return RECORD;
                }
<recname>{comments}   ;
<recname>{whiteSpace}   ;
<recname>{newline}   { ++line_num; return ENDL; } 
<recname>{ID}     { 
                    yylval.token=*newRECtoken(line_num,yytext);
                    if(!rType)
                            rType=newRType();
                    addRType(rType,yytext);
                    BEGIN(INITIAL);
                    return RECTYPE;
                    }
<recname>.             { 
                  BEGIN(INITIAL);
                  printf("Error(%d): Invalid or misplaced input character: \"%s\"\n", line_num, yytext);
                }



{digit}+        { 
                  yylval.token=*newNUMtoken(line_num,yytext,strtoll(yytext,NULL,10)); 
                  return NUMCONST; 
                }
[\(\)\{\}:;=,]  { yylval.token=*newKEYtoken(line_num,yytext); return SYMBOL;}
[\*\/\+-<>\?]   { yylval.token=*newKEYtoken(line_num,yytext); return SYMBOL;}
[\]\[%]         {yylval.token=*newKEYtoken(line_num,yytext); return SYMBOL;}

{ID}            { yylval.token=*newIDtoken(line_num,strdup(yytext)); return ID; }



.             { 
                  printf("Error(%d): Invalid or misplaced input character: \"%s\"\n", line_num, yytext);
                }

%%
 // user subroutine section 
 // No subroutine here because bison is taking care of it

