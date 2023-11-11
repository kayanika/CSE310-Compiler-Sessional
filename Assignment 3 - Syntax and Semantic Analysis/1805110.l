%option noyywrap

%x STRING_STATE
%x SINGLE_COMMENT_STATE
%x MULTI_COMMENT_STATE
%x DOUBLE_COMMENT_STATE


%{
#include<stdio.h>
#include<stdlib.h>
#include <bits/stdc++.h>
using namespace std;

#include "hp.h"
#include "y.tab.h"


extern int line_count;
extern
int currentLine=0;

//FILE *logout;
//FILE *tokenout;
extern YYSTYPE yylval;
 extern ofstream logout;
 extern ofstream errorOut;
 extern int errorCount;
 string currentString="";
  string currentString2="";
 string currentComment="";




%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE [\r]?\n
ALPHANUMERIC [A-Za-z_0-9]
CHAR ([^\\]-(\\[nt'\\afrbv0]\'))
SPECIAL_CHAR \\[nt'\\afrbv0]

%%


{WHITESPACE} {}

"if"  {
		symbolInfo *symbolinfo = new symbolInfo(yytext,"IF");
		
		yylval.symbol = symbolinfo;
		return IF;
	}   

"else"  {
			symbolInfo *symbolinfo = new symbolInfo(yytext,"ELSE");
			
			
			yylval.symbol = symbolinfo;
			return ELSE;
		}
		
"for"  {
			symbolInfo *symbolinfo = new symbolInfo(yytext,"FOR");
			
			
			yylval.symbol = symbolinfo;
			return FOR;
		}
		
"while"   {
			symbolInfo *symbolinfo = new symbolInfo(yytext,"WHILE");
			
			
			yylval.symbol = symbolinfo;
			return WHILE;
		}
		
"do"  {
			symbolInfo *symbolinfo = new symbolInfo(yytext,"DO");
			
			
			yylval.symbol = symbolinfo;
			return DO;
		}

"int"  {
			symbolInfo *symbolinfo = new symbolInfo(yytext,"INT");
			
		
			yylval.symbol = symbolinfo;
			return INT;
		}
		
"float" {
			symbolInfo *symbolinfo = new symbolInfo(yytext,"FLOAT");
			
			
			yylval.symbol = symbolinfo;
			return FLOAT;
		}
		
"void"  {
			symbolInfo *symbolinfo = new symbolInfo(yytext,"VOID");
			
			
			yylval.symbol = symbolinfo;
			return VOID;
		}	
		
"return"   {
			symbolInfo *symbolinfo = new symbolInfo(yytext,"RETURN");
			
		;
			yylval.symbol = symbolinfo;
			return RETURN;
		}	
		
"printf"  {
			symbolInfo *symbolinfo = new symbolInfo(yytext,"PRINTF");
			
			
			yylval.symbol = symbolinfo;
			return PRINTLN;
		}
		


		
{DIGIT}+ 	{
				 symbolInfo *symbol = new symbolInfo(yytext,"CONST_INT");
			cout<<"an intger "<<yytext<<endl;
			yylval.symbol = symbol;
			
			return CONST_INT;
				

			}
{DIGIT}+("."{DIGIT}+)?([E][+-]?{DIGIT}+)?	{

			symbolInfo *symbol = new symbolInfo(yytext,"CONST_FLOAT");
			
			yylval.symbol = symbol;
			return CONST_FLOAT;
			
			}
{DIGIT}*(\.{DIGIT}+)\.[0-9\.Ee+-]*(\.)* {
	errorCount++;
	logout<<"Error at line no :"<< line_count <<" Too many decimal points "<<yytext<<endl;
	errorOut<<"Error at line no :"<< line_count <<" Too many decimal points "<<yytext<<endl;
}
{DIGIT}+(\.{DIGIT}+)?[E]?(\.{DIGIT}+)?{ALPHANUMERIC}+  {
	errorCount++;
	logout<<"Error at line no :"<< line_count <<" Invalid prefix on ID or invalid suffix on Number :"<<yytext<<endl;
	errorOut<<"Error at line no :"<< line_count <<" Invalid prefix on ID or invalid suffix on Number :"<<yytext<<endl;
}

([0-9]*(\.[0-9]*)?[E][+-]?[0-9]*[0-9\.E+-]*(\.)*)|([0-9]+\.) {
	errorCount++;
	logout<<"Error at line no :"<< line_count <<": Ill formed number "<<yytext<<endl;
	errorOut<<"Error at line no :"<< line_count <<": Ill formed number "<<yytext<<endl;
}			
[A-Za-z_][a-zA-Z0-9_]*	{
	                         symbolInfo *symbolinfo = new symbolInfo(yytext,"ID");
		                   cout<<"got an ID   h"<<yytext<<"end ID VALUE "<<ID<<endl;
			yylval.symbol= symbolinfo;
			return ID;


		}
"+"|"-"	{
		symbolInfo *symbol = new symbolInfo(yytext,"ADDOP");
			
			yylval.symbol = symbol;
			return ADDOP;
}

"*"|"/"|"%"	{
	symbolInfo *symbol = new symbolInfo(yytext,"MULOP");
			
			yylval.symbol = symbol;
			return MULOP;
}

"++"	{
	 symbolInfo *symbol = new symbolInfo(yytext,"INCOP");
			
			yylval.symbol = symbol;
			return INCOP;	
}

"--"   {
	 symbolInfo *symbol = new symbolInfo(yytext,"DECOP");
			
			yylval.symbol = symbol;
			return DECOP;	
}

"<"|"<="|">"|">="|"=="|"!="	{
		symbolInfo *symbol = new symbolInfo(yytext,"RELOP");
		
			yylval.symbol = symbol;
			return RELOP;
}

"="	{
	symbolInfo *symbol = new symbolInfo(yytext,"ASSIGNOP");
			
			yylval.symbol = symbol;
			return ASSIGNOP;
}

"&&"|"||"	{
		symbolInfo *symbol = new symbolInfo(yytext,"LOGICOP");
			
			yylval.symbol = symbol;
			return LOGICOP;
}

"!"	{
		symbolInfo *symbol = new symbolInfo(yytext,"NOT");
			
			yylval.symbol = symbol;
			return NOT;
}

"("	{
		symbolInfo *symbol = new symbolInfo(yytext,"LPAREN");
			
			yylval.symbol = symbol;
			return LPAREN;
}

")"	{
		symbolInfo *symbol = new symbolInfo(yytext,"RPAREN");
			
			yylval.symbol = symbol;
			return RPAREN;
}

"{"	{   
		symbolInfo *symbol = new symbolInfo(yytext,"LCURL");
		
			yylval.symbol = symbol;
			return LCURL;
}

"}"	{
		symbolInfo *symbol = new symbolInfo(yytext,"RCURL");
			
			yylval.symbol = symbol;
			return RCURL;
}

"["	{
		symbolInfo *symbol = new symbolInfo(yytext,"LTHIRD");
			
			yylval.symbol = symbol;
			return LTHIRD;
}

"]"	{
		symbolInfo *symbol = new symbolInfo(yytext,"RTHIRD");
			
			yylval.symbol = symbol;
			return RTHIRD;
}

","	{
		symbolInfo *symbol = new symbolInfo(yytext,"COMMA");
			
			yylval.symbol = symbol;
			return COMMA;
}

";"	{
	symbolInfo *symbol = new symbolInfo(yytext,"SEMICOLON");
		
			yylval.symbol = symbol;
			return SEMICOLON;
}

\'[^\\\n\t\'\a\f\r\b\v\0]\' {
	string str="";
	str+=yytext[1];
	//tokenout<<"<CONST_CHAR,"<<yytext[1]<<"> ";
				//logout<<"Line no :"<< line_count <<" TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found --><CHAR_CONST, "<<str<<">"<<endl;
			   
				



}
                  





\'\\[nt'\\afrbv0]\'   {
	
	//this causes problems, use switch case here
	
	

	string str="";
	
	   char c=yytext[2];
	  

	
	
		
		if(c=='t')  str+="\t";
		else if(c=='n')str+="\n";
		else if(c== '\'')str+="\'";
		

		else if(c= 'a')str+="\a";
		else if( c='f')str+="\f";
	else 	if( c='r')str+="\r";
		else if(c= 'b')str+="\b";
	else 	if( c='v')str+="\v";
	else	if(c='0')str+="\0";
	
	

	
	cout<<"the string to be inserted"<<str<<endl;
	logout<<"the string to be inserted"<<str<<" yytext:"<<yytext<<endl;
	//tokenout<<"<CONST_CHAR,"<<str<<"> ";
				logout<<"Line no :"<< line_count <<" TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found --><CHAR_CONST, "<<str<<">"<<endl;
			  
				


	
}


\"   {
	currentString="";
	currentLine=line_count;
	logout<<"Beginning string state"<<endl;
	currentString2="";
	BEGIN STRING_STATE;

}
\/\/	{  currentComment="";
currentLine=line_count;
currentComment+=yytext;
cout<<"INSIDE SINGLE COMMENT NSTATE "<<endl;
    BEGIN SINGLE_COMMENT_STATE;


}

\/\*	{
           currentComment="";
		   currentLine=line_count;
		   currentComment+=yytext;
		   cout<<"inside multi comment state"<<endl;
		   BEGIN MULTI_COMMENT_STATE;

}
<STRING_STATE>\n 	{
	
	
	
	errorCount++;
	logout<<"Error at line no :"<< currentLine <<"Unfinished string error  "<<currentString<<endl;
	line_count++;
	BEGIN INITIAL;

}

<STRING_STATE>\\["t'\\afrbv0]   {
	
	string str="";
	
	   char c=yytext[1];
	   logout<<c<<endl;

	
	
		
		if(c=='t')  str+="\t";
		else if(c=='"')str+="\"";
		else if(c== '\'')str+="\'";
		

		else if(c= 'a')str+="\a";
		else if( c='f')str+="\f";
	else 	if( c='r')str+="\r";
		else if(c= 'b')str+="\b";
	else 	if( c='v')str+="\v";
	else	if(c='0')str+="\0";
	
	currentString+=yytext;
	currentString2+=str;
	


	
}



<STRING_STATE>\\\n 	{
	logout<<"adding slash yytext "<<yytext<<"end"<<endl;
	currentString+=yytext;
	
	line_count++;
}

<STRING_STATE><<EOF>> 	{
	
	
	errorCount++;
	logout<<"Error at line no :"<< currentLine <<"Unfinished string error  "<<currentString<<endl;
	BEGIN INITIAL;

}

<STRING_STATE>\\\r\n 	{
	
	currentString+="\r\n";
	line_count++;
}

<STRING_STATE>\" 	{
//	tokenout<<"<STRING,"<<currentString2<<">";
    logout<<"Line no "<< currentLine <<": Token " <<"<STRING>"<<" Lexeme \""<<currentString<< "\" found ---> <STRING, "<<currentString2<<">"<<endl;
    
	BEGIN INITIAL;
}


<STRING_STATE>. 	{   currentString+=yytext[0];  currentString2+=yytext[0]; 
	
}

<SINGLE_COMMENT_STATE>\\\n  {
	currentComment+="\\n";
	cout<<currentComment<<" : transfering to double comment state "<<endl;
    line_count++;
	BEGIN DOUBLE_COMMENT_STATE;


}
<SINGLE_COMMENT_STATE>\n  {
	currentComment+="\n";
	cout<<currentComment<<" : single comment finsihed "<<endl;
	logout<<"Line no "<<currentLine<<" Token <COMMENT> Lexeme "<<currentComment <<"found"<<endl;
    line_count++;
	BEGIN INITIAL;


}
<SINGLE_COMMENT_STATE>. 	{   currentComment+=yytext[0]; cout<<"currentComment "<<currentComment<<endl;
	
}

<DOUBLE_COMMENT_STATE>\\\n {
currentComment+="\\\n";
    line_count++;
	cout<<"double comment going on for another line :"<<currentComment<<endl;
}
<DOUBLE_COMMENT_STATE>[\r]?\n  {
	currentComment+="";
	cout<<"double comment finished "<<endl;
    line_count++;

	cout<<"current entire comment "<<currentComment<<endl;
	logout<<"Line no "<<currentLine<<" Token <COMMENT> Lexeme "<<currentComment <<"found"<<endl;
	BEGIN INITIAL;
}

<DOUBLE_COMMENT_STATE>. 	{   currentComment+=yytext[0]; cout<<yytext[0];
	
}
<MULTI_COMMENT_STATE>\*\/	{
	
	currentComment+=yytext;
     cout<<"MULTI STATEMENT COMMENT finsihed :"<<currentComment<<endl;
	 logout<<"Line no "<<currentLine<<" Token <COMMENT> Lexeme "<<currentComment <<"found"<<endl;
	 BEGIN INITIAL;

}
<MULTI_COMMENT_STATE>{NEWLINE} { line_count++; cout<<"line_count now :"<<line_count<<endl;}
<MULTI_COMMENT_STATE><<EOF>> 	{
	
	
	errorCount++;
	logout<<"Error at line no :"<< currentLine <<"Unfinished COMMENT error  "<<currentString<<endl;
	cout<<"Error at line no :"<< currentLine <<"Unfinished COMMENT error  "<<currentString<<endl;
	BEGIN INITIAL;
	

}
<MULTI_COMMENT_STATE>.	{ currentComment+=yytext[0]; cout<<"multi comment "<<currentComment<<" line count :"<<line_count<<endl;

    
}
{NEWLINE} {line_count++; }

"'"([^\\\'\n][^\\\'\n]+)"'" {
	errorCount++;
	logout<<"Error at line no :"<< line_count <<"multi character constant error : "<<yytext<<endl;



}
'(([^\\\'])|(\\[nt'\\afrbv0])) {
	errorCount++;
	logout<<"Error at line no : "<< line_count <<"Unfinished character error"<<yytext<<"yytext end"<<endl;
    if(yytext[1]=='\n')line_count++;


}
'' { errorCount++;
	logout<<"Error at line no : "<< line_count <<"empty character error"<<yytext<<"yytext end"<<endl;
	
}








. {
	errorCount++;
	logout<<"Error at line no "<< line_count <<": Unrecognized character "<<yytext<<"\n"<<endl;
	errorOut<<"Error at line no "<< line_count <<": Unrecognized character "<<yytext<<"\n"<<endl;

}




			

%%



