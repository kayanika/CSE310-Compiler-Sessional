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

#include "1805110.h"


int line_count=1;

//FILE *logout;
//FILE *tokenout;
 ofstream logout;
 ofstream tokenout;
 int errorCount=0;
 string currentString="";
  string currentString2="";
 string currentComment="";


symbolTable s1(7);

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE [\r]?\n
ALPHANUMERIC [A-Za-z_0-9]

%%

{NEWLINE} {line_count++;}
{WHITESPACE} {}

"if"|"else"|"for"|"while"|"do"|"break"|"int"|"char"|"float"|"double"|"void"|"return"|"switch"|"case"|"default"|"continue"	{
           
		   string s = "";
    for (int i = 0; i < yytext[i]; i++) {
		char c=toupper(yytext[i]);
        s = s + c;
	
    }			

			tokenout<<"<"<<s<<">";
		
			logout<<"Line no :" <<line_count<<" TOKEN <"<<s<<"> Lexeme "<<yytext<<" found"<<endl;
			
		}
		
\'\'  {
	errorCount++;
	logout<<"Error at line no "<< line_count <<": Empty character constant error"<<endl;
}

		
{DIGIT}+ 	{
				
				tokenout<<"<CONST_INT,"<<yytext<<">";
		               logout<<"Line no :" <<line_count<<" TOKEN <CONST_INT> Lexeme "<<yytext<<" found"<<endl;
				//insert in symbol table and print symbol table content(only non empty buckets)
				s1.insertNewSymbol(yytext,"CONST_INT",logout);
		s1.printAllScopeTable(logout);

			}
{DIGIT}+("."{DIGIT}+)?([E][+-]?{DIGIT}+)?	{

				tokenout<<"<CONST_FLOAT,"<<yytext<<"> ";
				logout<<"Line no :"<< line_count <<" TOKEN <CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl;
			
				s1.insertNewSymbol(yytext,"CONST_FLOAT",logout);
		s1.printAllScopeTable(logout);
			}
{DIGIT}*(\.{DIGIT}+)\.[0-9\.Ee+-]*(\.)* {
	errorCount++;
	logout<<"Error at line no :"<< line_count <<" Too many decimal points "<<yytext<<endl;
}

([0-9]*(\.[0-9]*)?[E][+-]?[0-9]*[0-9\.E+-]*(\.)*)|([0-9]+\.) {
	errorCount++;
	logout<<"Error at line no :"<< line_count <<": Ill formed number "<<yytext<<endl;
}			
{LETTER}+{ALPHANUMERIC}*	{
	                         string str=yytext;
	                tokenout<<"<ID,"<<yytext<<"> ";
				    logout<<"Line no :"<< line_count <<" TOKEN <ID> Lexeme "<<yytext<<" found"<<endl;
			cout<<"GOINT TO INSERT"<<endl;
			
				s1.insertNewSymbol(str,"ID",logout);
				
		       s1.printAllScopeTable(logout);


		}
"+"|"-"	{
		tokenout<<"<ADDOP,"<<yytext<<"> ";
		logout<<"Line no : "<< line_count <<" TOKEN " <<"<ADDOP>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"*"|"/"|"%"	{
		tokenout<<"<MULOP,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<" TOKEN " <<"<MULOP>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"++"|"--"	{
		tokenout<<"<INCOP,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<" TOKEN " <<"<INCOP>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"<"|"<="|">"|">="|"=="|"!="	{
		tokenout<<"<RELOP,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<" TOKEN " <<"<RELOP>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"="	{
		tokenout<<"<ASSIGNOP,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<" TOKEN " <<"<ASSIGNOP>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"&&"|"||"	{
		tokenout<<"<LOGICOP,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<" TOKEN " <<"<LOGICOP>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"!"	{
		tokenout<<"<NOT,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<" TOKEN " <<"<NOT>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"("	{
		tokenout<<"<LPAREN,"<<yytext<<"> ";
		logout<<"Line no "<< line_count <<": Token " <<"<LPAREN>"<<" Lexeme "<<yytext<<" found"<<endl;
}

")"	{
		tokenout<<"<RPAREN,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<" TOKEN " <<"<RPAREN>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"{"	{   
		tokenout<<"<LCURL,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<" Token " <<"<LCURL>"<<" Lexeme "<<yytext<<" found"<<endl;

		s1.enterScope();
}

"}"	{
		tokenout<<"<RCURL,"<<yytext<<"> ";
		logout<<"Line no "<< line_count <<": Token " <<"<RCURL>"<<" Lexeme "<<yytext<<" found"<<endl;

		s1.exitScope();
}

"["	{
		tokenout<<"<LTHIRD,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<" TOKEN " <<"<LTHIRD>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"]"	{
		tokenout<<"<RTHIRD,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<" TOKEN " <<"<RTHIRD>"<<" Lexeme "<<yytext<<" found"<<endl;
}

","	{
		tokenout<<"<COMMA,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<" TOKEN" <<"<COMMA>"<<" Lexeme "<<yytext<<" found"<<endl;
}

";"	{
		tokenout<<"<SEMICOLON,"<<yytext<<"> ";
		logout<<"Line no :"<< line_count <<": TOKEN " <<"<SEMICOLON>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"'"[^\\]"'" {
	string str=""+yytext[1];
	tokenout<<"<CONST_CHAR,"<<yytext[1]<<"> ";
				logout<<"Line no :"<< line_count <<" TOKEN <CONST_CHAR> Lexeme "<<yytext[1]<<" found"<<endl;
			    cout<<"reading characters "<<endl;
				if(s1.insertNewSymbol(str,"CONST_CHAR",logout))
	     	s1.printAllScopeTable(logout);



}
"'"[^\\] {
	errorCount++;
	logout<<"Error at line no :"<< line_count <<"Unfinished character error "<<endl;



}





\'\\[nt'\\afrbv0]\'   {
	string str="";
	//this causes problems, use switch case here
	

	switch(yytext[2]){
	
		case 'n': str+="\\n";break;
		case 't':str+="\\t";break;
		case '\'':str+="\\'";break;
		case '\\':str+="\\";break;
		case 'a':str+="\\a";break;
		case 'f':str+="\\f";break;
		case 'r':str+="\\r";break;
		case 'b':str+="\\b";break;
		case 'v':str+="\\v";break;
		case '0':str+="\\0";break;
		
	}
	
	
	cout<<"found this string inside "<<str<<endl;

	
	cout<<"the string to be inserted"<<str<<endl;
	tokenout<<"<CONST_CHAR,"<<str<<"> ";
			//	logout<<"Line no :"<< line_count <<" TOKEN <CONST_CHAR> Lexeme '"<<str<<"' found --><CHAR_CONST, "<<yytext<<">"<<endl;
			  
				s1.insertNewSymbol(str,"CONST_CHAR",logout);
	         	s1.printAllScopeTable(logout);


	
}


\"   {
	currentString="";
	currentString2="";
	BEGIN STRING_STATE;

}
\/\/	{  currentComment="";
cout<<"INSIDE SINGLE COMMENT NSTATE "<<endl;
    BEGIN SINGLE_COMMENT_STATE;

}

\/\*	{
           currentComment="";
		   cout<<"inside multi comment state"<<endl;
		   BEGIN MULTI_COMMENT_STATE;

}



<STRING_STATE>\\\n 	{
	currentString2+="\\n";
	currentString+="\n";
	line_count++;
}
<STRING_STATE>\\n 	{
	
	
	line_count++;
	errorCount++;
	logout<<"Error at line no :"<< line_count <<"Unfinished string error  "<<currentString<<endl;

}
<STRING_STATE><<EOF>> 	{
	
	
	errorCount++;
	logout<<"Error at line no :"<< line_count <<"Unfinished string error  "<<currentString<<endl;

}

<STRING_STATE>\\\r\n 	{
	currentString2+="\\r\\n";
	currentString+="\r\n";
	line_count++;
}

<STRING_STATE>\" 	{
	tokenout<<"<STRING,"<<currentString<<">";
    logout<<"Line no "<< line_count <<": Token " <<"<STRING>"<<" Lexeme "<<currentString<<" found "<<endl;
    
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
<SINGLE_COMMENT_STATE>. 	{   currentComment+=yytext[0];
	
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
	BEGIN INITIAL;
}

<DOUBLE_COMMENT_STATE>. 	{   currentComment+=yytext[0]; cout<<yytext[0];
	
}
<MULTI_COMMENT_STATE>\*\/	{
     cout<<"MULTI STATEMENT COMMENT finsihed :"<<currentComment<<endl;
	 BEGIN INITIAL;

}
<MULTI_COMMENT_STATE>.	{ currentComment+=yytext[0];

     cout<<"MULTI STATEMENT COMMENT finsihed :"<<currentComment<<endl;
	 BEGIN INITIAL;

}




. {
	errorCount++;
	logout<<"Error at line no "<< line_count <<": Unrecognized character "<<yytext<<"\n"<<endl;
}




			

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout.open("1805110Log.txt");
	tokenout.open("1805110Token.txt");
  cout<<"Aa"<<endl;
	yyin= fin;
	yylex();
	fclose(yyin);
	//fclose(tokenout);
	//fclose(logout);
	return 0;

}
