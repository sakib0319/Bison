%option noyywrap

%x STRING
%x SINGLECMNT
%x MULTICMNT

%{

#include<iostream>
#include<cstdio>
#include<cstdlib>
#include<string>
#include<string.h>
#include"1605081.cpp"
#include"y.tab.h"
using namespace std;

extern YYSTYPE yylval;
extern SymbolTable *table;
void yyerror(char *);
extern FILE *ferrors;
int line_count = 1;
int error_count = 0;

string logoutput,tokenoutput;
string logoutputSingleCmnt;
string logoutputMultiCmnt;
int lineString=0,lineSingle=0,lineMult=0;
%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
ADDOP [+-] 
MULOP [*/%]

%%

{NEWLINE} {line_count++;}
{WHITESPACE} {}


"if" {return IF;}

"else" {return ELSE;}

"for" {return FOR;}

"while" {return WHILE;}

"int" {return INT;}

"float" {return FLOAT;}

"double" {return DOUBLE;}

"char" {return CHAR;}

"return" {return RETURN;}

"void" {return VOID;}

"println" {return PRINTLN;}

"do" {return DO;}

"break"	{return BREAK;}

"switch" {return SWITCH;}		

"case" {return CASE;}

"default" {return DEFAULT;}

"continue" {return CONTINUE;}

{ADDOP} { 
			Symbolinfo *s= new  Symbolinfo(yytext, (char *)"ADDOP");
			yylval.value = (Symbolinfo*)s;
			return ADDOP;
		}

{MULOP}	{
			Symbolinfo *s= new  Symbolinfo(yytext, (char *)"MULOP");
			yylval.value = (Symbolinfo*)s;
			return MULOP;
		}

"<"			|

"<="		|

">"			|

">="		|

"=="		|

"!="	{
			Symbolinfo *s= new  Symbolinfo(yytext, (char *)"RELOP");
			yylval.value = (Symbolinfo*)s;
			return RELOP;
		}

"&&"		|

"||"	{
			Symbolinfo *s= new  Symbolinfo(yytext, (char *)"LOGICOP");
			yylval.value = (Symbolinfo*)s;
			return LOGICOP;
		}

"&"			|

"^"			|

">>"		|

"<<"		|

"|"		{
			Symbolinfo *s= new  Symbolinfo(yytext, (char *)"BITOP");
			yylval.value = (Symbolinfo*)s;
			return BITOP;
		}

"="		{return ASSIGNOP;}

"++"    {return INCOP;}

"--"    {return DECOP;}

"!"		{return NOT;}

"("		{return LPAREN;}

")"		{return RPAREN;}

"{"		{return LCURL;}		

"}"		{return RCURL;}

"["		{return LTHIRD;}

"]"		{return RTHIRD;}

","		{return COMMA;}

";"		{return SEMICOLON;}


{DIGIT}+ 	{
				Symbolinfo *s= new  Symbolinfo(yytext, (char *)"CONST_INT");
				yylval.value = (Symbolinfo*)s;
				return CONST_INT;
			}

({DIGIT}*[\.]{DIGIT}+|{DIGIT}+[\.]?)(E(-)?{DIGIT}+)? {

				Symbolinfo *s= new  Symbolinfo(yytext, (char *)"CONST_FLOAT");
				yylval.value = (Symbolinfo*)s;
				return CONST_FLOAT;
			}

'' {
	 error_count++; 
 }

'[^\\\n]'	{	
				Symbolinfo *s= new  Symbolinfo((char *)yytext[1], (char *)"CONST_CHAR");
				yylval.value = (Symbolinfo*)s;
				return CONST_CHAR;
			} 

'\\n' {
				Symbolinfo *s= new  Symbolinfo((char *)'\n', (char *)"CONST_CHAR");
				yylval.value = (Symbolinfo*)s;
				return CONST_CHAR;
}

'\\t' {
				Symbolinfo *s= new  Symbolinfo((char *)'\t', (char *)"CONST_CHAR");
				yylval.value = (Symbolinfo*)s;
				return CONST_CHAR;
}

'\\a' {
				Symbolinfo *s= new  Symbolinfo((char *)'\a', (char *)"CONST_CHAR");
				yylval.value = (Symbolinfo*)s;
				return CONST_CHAR;
}

'\\f' {
				Symbolinfo *s= new  Symbolinfo((char *)'\f', (char *)"CONST_CHAR");
				yylval.value = (Symbolinfo*)s;
				return CONST_CHAR;
}

'\\r' {
				Symbolinfo *s= new  Symbolinfo((char *)'\r', (char *)"CONST_CHAR");
				yylval.value = (Symbolinfo*)s;
				return CONST_CHAR;
}

'\\b' {
				Symbolinfo *s= new  Symbolinfo((char *)'\b', (char *)"CONST_CHAR");
				yylval.value = (Symbolinfo*)s;
				return CONST_CHAR;
}

'\\v' {
				Symbolinfo *s= new  Symbolinfo((char *)'\v', (char *)"CONST_CHAR");
				yylval.value = (Symbolinfo*)s;
				return CONST_CHAR;
}

'\\0' {
				Symbolinfo *s= new  Symbolinfo((char *)'\0', (char *)"CONST_CHAR");
				yylval.value = (Symbolinfo*)s;
				return CONST_CHAR;
}

'\\\\' {
				Symbolinfo *s= new  Symbolinfo((char *)'\\', (char *)"CONST_CHAR");
				yylval.value = (Symbolinfo*)s;
				return CONST_CHAR;
}
 
[a-zA-Z_][a-zA-Z0-9_]* {
				Symbolinfo* s = new Symbolinfo((char *)yytext, (char *)"ID");
				yylval.value = (Symbolinfo*)s;
				return ID;

}

\" { 
	BEGIN STRING;
	logoutput = logoutput + yytext;
	tokenoutput = tokenoutput + yytext;
	lineString = line_count;
}

<STRING>[^\\\"\n] {
	logoutput = logoutput + yytext;
	tokenoutput = tokenoutput + yytext;
}

<STRING>\\[^ntafrbv0\\\n] {
			logoutput = logoutput+yytext;
			tokenoutput = tokenoutput+yytext[1];
}

<STRING>\\n {
				logoutput = logoutput + yytext;
				tokenoutput = tokenoutput + '\n';
				}
<STRING>\" {
				BEGIN INITIAL;
				logoutput = logoutput + yytext;
				tokenoutput = tokenoutput + yytext;
				
				logoutput = "";
				tokenoutput = "";
}

<STRING>\\t {
				logoutput = logoutput + yytext;
				tokenoutput = tokenoutput + '\t';
}

<STRING>\\a {
				logoutput = logoutput + yytext;
				tokenoutput = tokenoutput + '\a';
}

<STRING>\\f {
				logoutput = logoutput + yytext;
				tokenoutput = tokenoutput + '\f';
}

<STRING>\\r {
				logoutput = logoutput + yytext;
				tokenoutput = tokenoutput + '\r';
}

<STRING>\\b {
				logoutput = logoutput + yytext;
				tokenoutput = tokenoutput + '\b';
}

<STRING>\\v {
				logoutput = logoutput + yytext;
				tokenoutput = tokenoutput + '\v';
}

<STRING>\\0 {
				logoutput = logoutput + yytext;
				tokenoutput = tokenoutput + '\0';
}

<STRING>\\\\ {
				logoutput = logoutput + yytext;
				tokenoutput = tokenoutput + '\\';
}

<STRING>\\\n 	{
				logoutput = logoutput + yytext ;
				line_count++;
}

<STRING>\n {
	error_count++;
	line_count++;
	logoutput = "";
	BEGIN INITIAL;
}

"//" {
				BEGIN SINGLECMNT;
				lineSingle = line_count ;
				logoutputSingleCmnt = logoutputSingleCmnt + yytext;
}
<SINGLECMNT>[^\n] {
				logoutputSingleCmnt = logoutputSingleCmnt + yytext ;
}

<SINGLECMNT>\n {
	BEGIN INITIAL;
	line_count++;
	logoutputSingleCmnt = "";			
}

<SINGLECMNT>\\\n {
				logoutputSingleCmnt = logoutputSingleCmnt + yytext ;
				line_count++;
}

"/*" {
				BEGIN MULTICMNT;
				lineMult = line_count;
				logoutputMultiCmnt = logoutputMultiCmnt + yytext ;
}

<MULTICMNT>([^*\n])|. {
	logoutputMultiCmnt = logoutputMultiCmnt + yytext ;
}
<MULTICMNT>\n {
	logoutputMultiCmnt = logoutputMultiCmnt + '\n' ;
	line_count++;
}

<MULTICMNT>"*/" {
	BEGIN INITIAL;
	logoutputMultiCmnt = logoutputMultiCmnt + yytext ;
	logoutputMultiCmnt = "";
}
<MULTICMNT><<EOF>> {
	error_count++;
	BEGIN INITIAL;
	logoutputMultiCmnt = "";
}


{DIGIT}*[\.]({DIGIT}+[\.])+{DIGIT}* {
	error_count++;
}

{DIGIT}*([\.])*{DIGIT}+(E(-)?{DIGIT}+)([\.])+{DIGIT}* {
	error_count++;
}

{DIGIT}+[a-zA-Z]+{DIGIT}* {
	error_count++;
}

'..+' {
	error_count++;
}

'. |
' |
'\\[ntafrbv0\\] |
'\\' {
	error_count++;
}

'\[^ntafrbv0\\\n]' {
	error_count++;
}

%%


