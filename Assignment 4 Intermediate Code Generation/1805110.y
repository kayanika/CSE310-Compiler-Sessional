%{


#include "hp.h"



using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
int line_count=1;
int errorCount=0;
 ofstream logout;
 ofstream errorOut;
 string start="start";
 string eval="eval";
 string stmt="stmt";
 string ext="exit";
 string WhileStart="";
 string WhileExt="";
 ofstream check;
 int SP_VAL;
 string elseStatement="";
 string IfEndStatment="";

 ofstream asmOut;
 int currentLabel=0;
 vector<string> globalVaribales;

 
 
 
 vector<pair<string,string>> funcParameters;
 //parameters are being saved like <int,a>
 
 bool newScope;

symbolTable *table=new symbolTable(7);
vector<string> arglist;

void writeInitial(){
	
}
string currentScopeId(){
    return table->getCurrentScopeTableID();
}
void addPrintProcedure(){
	asmOut<<" \r\nPRINTLN PROC\r\n               \r\n        MOV CX , 0FH     \r\n        PUSH CX ; marker\r\n        \r\n        MOV IS_NEG, 0H\r\n        MOV AX , FOR_PRINT\r\n        TEST AX , 8000H\r\n        JE OUTPUT_LOOP\r\n                    \r\n        MOV IS_NEG, 1H\r\n        MOV AX , 0FFFFH\r\n        SUB AX , FOR_PRINT\r\n        ADD AX , 1H\r\n        MOV FOR_PRINT , AX\r\n\r\n    OUTPUT_LOOP:\r\n    \r\n        ;MOV AH, 1\r\n        ;INT 21H\r\n        \r\n        MOV AX , FOR_PRINT\r\n        XOR DX,DX\r\n        MOV BX , 10D\r\n        DIV BX ; QUOTIENT : AX  , REMAINDER : DX     \r\n        \r\n        MOV FOR_PRINT , AX\r\n        \r\n        PUSH DX\r\n        \r\n        CMP AX , 0H\r\n        JNE OUTPUT_LOOP\r\n        \r\n        ;LEA DX, NEWLINE ; DX : USED IN IO and MUL,DIV\r\n        ;MOV AH, 9 ; AH,9 used for character string output\r\n        ;INT 21H;\r\n\r\n        MOV AL , IS_NEG\r\n        CMP AL , 1H\r\n        JNE OP_STACK_PRINT\r\n        \r\n        MOV AH, 2\r\n        MOV DX, '-' ; stored in DL for display \r\n        INT 21H\r\n            \r\n        \r\n    OP_STACK_PRINT:\r\n    \r\n        ;MOV AH, 1\r\n        ;INT 21H\r\n    \r\n        POP BX\r\n        \r\n        CMP BX , 0FH\r\n        JE EXIT_OUTPUT\r\n        \r\n       \r\n        MOV AH, 2\r\n        MOV DX, BX ; stored in DL for display \r\n        ADD DX , 30H\r\n        INT 21H\r\n        \r\n        JMP OP_STACK_PRINT\r\n\r\n    EXIT_OUTPUT:\r\n    \r\n        ;POP CX \r\n\r\n        LEA DX, NEWLINE\r\n        MOV AH, 9 \r\n        INT 21H\r\n    \r\n        RET     \r\n      \r\nPRINTLN ENDP"<<endl;

   
}



	






string createNewLabel(){
	string label_="";
	currentLabel++;
	label_= "Label_"+to_string(currentLabel);
	cout<<label_;
	return label_;
}
void createNewLocalVariable(){
	//increment sp printVoidFunctionError
     
}
string getVariable(symbolInfo* temp){
	string str="";
	if(temp->getStackOffset()==0){
	
		str=temp->getName();
	}
		else {
			
				str=str+to_string(temp->getStackOffset())+"[BP]";
				
		}
		return str;
}

void yyerror(char const *s)
{   errorCount++;
	  cout<<"at line no : "<<line_count<<endl;
	  logout<<" Error at line no : "<<line_count<<" "<<s<<endl;
	  errorOut<<" Error at line no : "<<line_count<<" "<<s<<endl;
	  fprintf (stderr, "%s\n", s);

}
bool printVoidFunctionError(string a,string b){
	if(a=="VOID" || b=="VOID"){ errorCount++;
	logout<<"Error at line no :"<<line_count<<" Void function used in expression"<<endl;
	errorOut<<"Error at line no :"<<line_count<<" Void function used in expression"<<endl;return true;}
return false;}
void printCurrentLine(hp* curr){
	
	for(int i=0;i<curr->size();i++){
		
		logout<<curr->at(i)->getName();
		if(curr->at(i)->getName()=="int"||curr->at(i)->getName()=="float"||curr->at(i)->getName()=="void"||curr->at(i)->getName()=="return")
			logout<<" ";

			if(curr->at(i)->getName()=="{"||curr->at(i)->getName()=="}"||curr->at(i)->getName()==";")
	         logout<<endl;	
		
	}logout<<endl; 
}





%}
%define parse.error verbose
%union{

	hp *vctr;
	symbolInfo *symbol;
}

%token<symbol> IF ELSE FOR WHILE BREAK DO INT CHAR FLOAT VOID RETURN CONTINUE  NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD PRINTLN SWITCH CASE DEFAULT
%token<symbol>  COMMA SEMICOLON ADDOP MULOP INCOP DECOP LOGICOP RELOP ASSIGNOP 
%token<symbol> ID  CONST_INT CONST_FLOAT MAIN DOUBLE

%type<symbol> type_specifier
%type<vctr> declaration_list var_declaration func_declaration parameter_list unit factor 
%type<vctr> unary_expression term simple_expression rel_expression logic_expression expression variable expression_statement 
%type<vctr> arguments argument_list statement statements compound_statement func_definition program
%type<vctr> if_statement

%left ADDOP 
%left MULOP
%left RELOP 
%left LOGICOP 
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start :{    
		asmOut<<endl<<".MODEL SMALL\n.STACK 1000H\n.DATA"<<endl;
		 asmOut<<"IS_NEG DB ?"<<endl;
    asmOut<<"FOR_PRINT DW ?"<<endl;
   asmOut<<"CR EQU 0DH\nLF EQU 0AH\nNEWLINE DB CR, LF , '$' "<<endl;
		
		asmOut<<".CODE "<<endl;
		addPrintProcedure();
	
		
	   
	} program {    
	
		
	    printCurrentLine($2);
	}
	
	;

program : program unit {
	cout<<"program : program unit"<<endl;
     logout<<"Line no : "<<line_count<<" program : program unit"<<endl;
	  $$=new hp();
	  for(int i=0;i<$1->size();i++){
		$$->push($1->at(i));
	  }
	    for(int i=0;i<$2->size();i++){
		$$->push($2->at(i));
	  }
	  printCurrentLine($$);
	 }
	| unit {
		cout<<"program : unit"<<endl;
		logout<<"Line no : "<<line_count<<" program : unit"<<endl;
	
		 $$=new hp();
	for(int i=0;i<$1->size();i++){
		$$->push($1->at(i));
	}
	printCurrentLine($$);
	}
    
        
       
         
	;
	
unit : var_declaration {
	cout<<"unit : var_declaration "<<endl;
	logout<<"Line no : "<<line_count<<" unit : var_declaration"<<endl;
	 $$=new hp();
	for(int i=0;i<$1->size();i++){
		$$->push($1->at(i));
	}
	printCurrentLine($$);
	//assembly code, this is for the global variables only
	
	
	
	}
     | func_declaration {
		 cout<<"unit : func_declaration "<<endl;
		 logout<<"Line no : "<<line_count<<" unit : func_declaration "<<endl;
	 $$=new hp();
	for(int i=0;i<$1->size();i++){
		$$->push($1->at(i));
	}
	printCurrentLine($$);
		 }
     | func_definition {
		  cout<<"unit : func_definition "<<endl;
		 logout<<"Line no : "<<line_count<<" unit : func_definition "<<endl;
	 $$=new hp();
	for(int i=0;i<$1->size();i++){
		$$->push($1->at(i));
	}
	printCurrentLine($$);
		
		 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
	cout<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;
	logout<<"line no : "<<line_count<<" func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;
	
	
	
	$$=new hp();
	$$->push($1);
	

	if(table->lookUpSymbol($2->getName())!=nullptr){
		logout<<"Error at line no : "<<line_count<<" Multiple declaration with this name -"<<$2->getName()<<endl;
		errorOut<<"Error at line no : "<<line_count<<" Multiple declaration with this name -"<<$2->getName()<<endl;
	errorCount++;}
	//2.save ID in the symbol table, along with the paramters and return type
	//3.push everything in $$vector

	bool inserted=table->insertNewSymbol($2->getName(),"ID",logout);
	if(inserted){
		cout<<"hasn't been declared before : func dec"<<endl;
		symbolInfo* tempSymbol=table->lookUpSymbol($2->getName());
		tempSymbol->setVariableType("func");
		tempSymbol->setReturnType($1->getType());
		tempSymbol->setAlreadyDefined();
		for(int i=0;i<funcParameters.size();i++){

			tempSymbol->addParameter(funcParameters.at(i).first,funcParameters.at(i).second);
			 if(funcParameters.at(i).second==""){
								  
                                           cout<<"Error at line no : "<<line_count<<"parameter doesn't have a name"<<endl;
							 logout<<"Error at line no : "<<line_count<<" parameter doesn't have a name"<<endl;
							 errorOut<<"Error at line no : "<<line_count<<" parameter doesn't have a name"<<endl;
							 errorCount++;}
			
			
			

		} funcParameters.clear();
		$$->push($2);$$->push($3);
		
		for(int i=0; i<$4->size();i++){
			$$->push($4->at(i));
			
		}



	 //clear the func parameters vector
	 
	 $$->push($5);$$->push($6);

		printCurrentLine($$);

	}

 $$->setVarType($1->getType());	
}
		| type_specifier ID LPAREN RPAREN SEMICOLON {
			cout<<"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl;
			
	logout<<"line no : "<<line_count<<" func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl;
	$$=new hp();
	$$->push($1);
	

	if(table->lookUpSymbol($2->getName())!=nullptr){
		logout<<"Error at line no : "<<line_count<<" Multiple declaration with this name -"<<$2->getName()<<endl;
		errorOut<<"Error at line no : "<<line_count<<" Multiple declaration with this name -"<<$2->getName()<<endl;
	errorCount++;
	}
	
	
	
	$$=new hp();
	$$->push($1);
	
       
	if(table->lookUpSymbol($2->getName())!=nullptr){
		logout<<"Error at line no : "<<line_count<<" Multiple declaration of "<<$2->getName()<<endl;
		errorOut<<"Error at line no : "<<line_count<<" Multiple declaration of "<<$2->getName()<<endl;
	errorCount++;}
	bool inserted=table->insertNewSymbol($2->getName(),"ID",logout);
	if(inserted){
		symbolInfo* tempSymbol=table->lookUpSymbol($2->getName());
		tempSymbol->setVariableType("func");
		tempSymbol->setReturnType($1->getType());
		tempSymbol->setAlreadyDefined();
			}
			$$->push($2);$$->push($3);
			$$->push($4);$$->push($5);
       $$->setVarType($1->getType());	
		printCurrentLine($$);

		}
		;



func_definition : type_specifier ID  LPAREN parameter_list  RPAREN {
	//Remember, you have to check every ID for offset and if they are [function OR ARRAY OR VARIBALE]
          bool inserted=false;
		   bool insertInTable=false;
		   cout<<"inserted "<<inserted<<" false"<<endl;
        
            if(table->lookUpSymbol($2->getName())==nullptr)
				
				 inserted=table->insertNewSymbol($2->getName(),"ID",logout);
				 cout<<"inserted "<<" ,aybe done"<<endl;
				symbolInfo* tempSymbol=table->lookUpSymbol($2->getName());
				cout<<"inserted "<<inserted<<" done"<<endl;

	         if(inserted){
				
				
				 insertInTable=true;
		
		tempSymbol->setVariableType("func");
		cout<<"inserted setVariableTypefunc "<<tempSymbol->getVariableType()<<" done"<<endl;;
		tempSymbol->setReturnType($1->getType());
		tempSymbol->setAlreadyDefined();
		for(int i=0;i<funcParameters.size();i++){

			tempSymbol->addParameter(funcParameters.at(i).first,funcParameters.at(i).second);
			if(funcParameters.at(i).second==""){
								  
                                           cout<<"Error at line no : "<<line_count<<"parameter doesn't have a name"<<endl;
							 logout<<"Error at line no : "<<line_count<<" parameter doesn't have a name"<<endl;
							 errorOut<<"Error at line no : "<<line_count<<" parameter doesn't have a name"<<endl;
							errorCount++; }
			}
			
			} 
			
			else{
				
				if(tempSymbol->getAlreadyDefined()){
					insertInTable=true;
					cout<<"has been dcelared, not defined"<<endl;
                      if(tempSymbol->getReturnType()!=$1->getType()){//checking for retrun type
                          cout<<"Error at line no : "<<line_count<<" Return type mismatch with function declaration in function "<<tempSymbol->getName()<<endl;
							 logout<<"Error at line no : "<<line_count<<" Return type mismatch with function declaration in function "<<tempSymbol->getName()<<endl;
							 errorOut<<"Error at line no : "<<line_count<<" Return type mismatch with function declaration in function "<<tempSymbol->getName()<<endl;
							errorCount++;
							 tempSymbol->setReturnType($1->getType());
					  }
					
				
                        //now check for parameter size, mismatch
						vector<pair<string,string>>  temp_parameters=tempSymbol->getParameters();
                       bool mismatch=false;
						if(funcParameters.size()!=temp_parameters.size()){
							mismatch=true;
                             cout<<"Error at line no : "<<line_count<<" number of parameters doesn't match with declaration "<<tempSymbol->getName()<<endl;
							 logout<<"Error at line no : "<<line_count<<" Total number of arguments mismatch with declaration in function "<<tempSymbol->getName()<<endl;
							 errorOut<<"Error at line no : "<<line_count<<" number of parameters doesn't match with declaration "<<tempSymbol->getName()<<endl;
						errorCount++;}
						else { for(int i=0;i<funcParameters.size();i++){
                             if( funcParameters.at(i).first!=temp_parameters.at(i).first){
								 mismatch=true;
								cout<<"Error at line no : "<<line_count<<": "<<i<<"th parameter type doesn't match with declaration"<<endl;
							 logout<<"Error at line no : "<<line_count<<": "<<i<<"th parameters type doesn't match with declaration"<<endl;
							  errorOut<<"Error at line no : "<<line_count<<": "<<i<<"th parameters type doesn't match with declaration"<<endl;
							 errorCount++;
							 }
							 if(funcParameters.at(i).second==""){
								  
                                           errorOut<<"Error at line no : "<<line_count<<"parameter doesn't have a name"<<endl;
							 logout<<"Error at line no : "<<line_count<<" parameter doesn't have a name"<<endl;
							errorCount++; }
						}
				} //now store the parameters again

				
				

						
				}
				else{
					//has been declared mutiple times
					cout<<"has been defined before"<<endl;
					cout<<"Error at line no : "<<line_count<<" Multiple declaration of "<<$2->getName()<<endl;
					logout<<"Error at line no : "<<line_count<<" Multiple declaration of "<<$2->getName()<<endl;
		errorOut<<"Error at line no : "<<line_count<<" Multiple declaration of "<<$2->getName()<<endl;

errorCount++;
			}tempSymbol->clearFuncParameters();
				for(int i=0;i<funcParameters.size();i++){
						

			tempSymbol->addParameter(funcParameters.at(i).first,funcParameters.at(i).second);
				
			}
			
					
			
}	table->enterScope();
			newScope=true;
			for(int i=0;i<funcParameters.size();i++){
				bool insertion=false;
					if(funcParameters.at(i).second!=""){
                    insertion=  table->insertNewSymbol(funcParameters.at(i).second,"ID",logout);
					check<<"check offset"<<(2*i)+4<<endl;
					if(insertion){
						symbolInfo* tempVar=table->searchSymbol(funcParameters.at(i).second);
						tempVar->setTypeSpecifier(funcParameters.at(i).first);
						tempVar->setStackOffset((2*i+4));
						check<<"check offset"<<tempVar->getStackOffset()<<endl;
					}
			}
			
			
}

//assembly code 
asmOut<<$2->getName()<<" PROC"<<endl; if($2->getName()=="main")asmOut<<"\tMOV AX, @DATA\n\tMOV DS, AX\n"<<endl;
asmOut<<"\tPUSH BP\n\tMOV BP , SP"<<endl;




} compound_statement {  
	
	
	cout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl;
	logout<<"func_definition : "<<line_count <<" type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl;
	 $$=new hp();
         $$->push($1);
		  $$->push($2);
		  $$->push($3);
		
		for(int i=0; i<$4->size();i++){
			$$->push($4->at(i));
			
		}
		$$->push($5);
		for(int i=0; i<$7->size();i++){
			$$->push($7->at(i));
			
		}
		
		printCurrentLine($$);
		 $$->setVarType($1->getType());	
		 if(SP_VAL!=0){
		 asmOut<<"\tADD SP,"<<SP_VAL<<endl;}
		
		 asmOut<<"\tPOP BP"<<endl;
		 if($2->getName()=="main")
                {
                   asmOut<< "\n;DOS EXIT\nMOV AH,4ch\nINT 21h\n";
                }
		 asmOut<<"\tRET "<<funcParameters.size()*2<<endl;

		 asmOut<<"\t"<<$2->getName()<<" ENDP"<<endl;
		 if($2->getName()=="main") asmOut<< "END MAIN\n";
       SP_VAL=0;
	   funcParameters.clear();
	
	}
		| type_specifier ID LPAREN RPAREN {
              bool inserted=false;
                 
			if(table->lookUpSymbol($2->getName())==nullptr){
                   inserted= table->insertNewSymbol($2->getName(),"ID",logout);     
			}
			symbolInfo* temp=table->lookUpSymbol($2->getName());
			if(!inserted && temp->getAlreadyDefined() ){
				if((temp->getReturnType()!=$1->getType())){
				errorCount++;
                        cout<<"Error at line no : "<<line_count<<" return type doesn't doesn't match with declaration"<<endl;
							 logout<<"Error at line no : "<<line_count<<"return type doesn't match with declaration"<<endl;
							 errorOut<<"Error at line no : "<<line_count<<"return type doesn't match with declaration"<<endl;
							 temp->setReturnType($1->getType());
					}	}
			else if(inserted){
				temp->setReturnType($1->getType());
				temp->setAlreadyDefined();
				temp->setVariableType("func");

			}
			else{ errorCount++;
				logout<<"Error at line no : "<<line_count<<" Multiple declaration of"<<$2->getName()<<endl;
		errorOut<<"Error at line no : "<<line_count<<" Multiple declaration of"<<$2->getName()<<endl;

			}


			table->enterScope();
			newScope=true;
			//assembly code 
asmOut<<$2->getName()<<" PROC"<<endl; if($2->getName()=="main")asmOut<<"\tMOV AX, @DATA\n\tMOV DS, AX\n"<<endl;
asmOut<<"\tPUSH BP\n\tMOV BP , SP"<<endl;

		} compound_statement  {

			cout<<"func_definition :type_specifier ID LPAREN RPAREN compound_statement"<<endl;
		logout<<"Line no : "<<line_count<<" func_definition :type_specifier ID LPAREN RPAREN compound_statement"<<endl;
	
		$$=new hp();
         $$->push($1);
		  $$->push($2);
		  $$->push($3);
		
		
		$$->push($4);
		for(int i=0; i<$6->size();i++){
			$$->push($6->at(i));
			
		}
		
		printCurrentLine($$);
		 $$->setVarType($1->getType());	
		 if(SP_VAL!=0){
		 asmOut<<"\tADD SP,"<<SP_VAL<<endl;}
		
		 asmOut<<"\tPOP BP"<<endl;
		 if($2->getName()=="main")
                {
                   asmOut<< "\n;DOS EXIT\nMOV AH,4ch\nINT 21h\n";
                }
		 
		 asmOut<<"\tRET "<<funcParameters.size()<<endl;
		  asmOut<<"\t"<<$2->getName()<<" ENDP"<<endl;
		  if($2->getName()=="main") asmOut<< "END MAIN\n";
     
		  SP_VAL=0;
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {

     bool multDeclare=false;    
	$$=new hp()  ;              
	cout<<"parameter_list  : parameter_list COMMA type_specifier ID "<<endl;
	logout<<"Line no "<<line_count<<" parameter_list  : parameter_list COMMA type_specifier ID "<<endl;
	funcParameters.push_back(make_pair($3->getType(),$4->getName()));
	 logout<<"size : "<<funcParameters.size()<<endl;
	for(int i=0;i<$1->size();i++){
		if($1->at(i)->getName()==$4->getName())
		multDeclare=true;
	
		$$->push($1->at(i));
	}
	if(multDeclare){ errorCount++;
		logout<<"Error at line "<<line_count<< ": Multiple declaration of "<<$4->getName()<<" in parameter"<<endl;
					errorOut<<"Error at line "<<line_count<< ": Multiple declaration of "<<$4->getName()<<" in parameter"<<endl;
	}
	
	$$->push($2);
	$$->push($3);
	$$->push($4);
printCurrentLine($$);
	

	}
		| parameter_list COMMA type_specifier {
			$$=new hp()  ;

			funcParameters.push_back(make_pair($3->getType(),""));
			logout<<"size : "<<funcParameters.size()<<endl;
			cout<<"parameter_list  : parameter_list COMMA type_specifier  "<<endl;
			logout<<"Line no : "<<line_count<<" parameter_list  : parameter_list COMMA type_specifier"<<endl;
			for(int i=0;i<$1->size();i++){
	
		$$->push($1->at(i));
	}

	$$->push($2);
	$$->push($3);
	printCurrentLine($$);
			
			}
 		| type_specifier ID {
			 cout<<"parameter_list :type_specifier ID"<<endl;

		 logout<<"Line no "<<line_count<<" parameter_list :type_specifier ID"<<endl;
		 $$=new hp()  ;
		        funcParameters.push_back(make_pair($1->getType(),$2->getName()));
				logout<<"size : "<<funcParameters.size()<<endl;
				
	$$->push($1);
	$$->push($2);
	printCurrentLine($$);
		 }
		| type_specifier { 
			$$=new hp();
			
			cout<<"parameter_list :type_specifier "<<endl;
		   
		 funcParameters.push_back(make_pair($1->getType(),""));
		 logout<<"size : "<<funcParameters.size()<<endl;
		
	$$->push($1);
	printCurrentLine($$);
		
		}
 		;

 		
compound_statement : LCURL {if(!newScope)table->enterScope();newScope=false;
} statements RCURL {

	cout<<"compound_statement : LCURL statements RCURL"<<endl;
	logout<<"Line no : "<<line_count<<" compound_statement : LCURL statements RCURL"<<endl;
	$$=new hp;
	$$->push($1);
	for(int i=0;i<$3->size();i++){
		$$->push($3->at(i));
	}
	$$->push($4);
	printCurrentLine($$);

	
		table->printAllScopeTable(logout);
		table->exitScope();
	}
 		    | LCURL{if(!newScope)table->enterScope();newScope=false;
			 } RCURL {
				 $$=new hp;
				 $$->push($1);
				 $$->push($3);
				
				 cout<<"compound_statement :LCURL RCURL "<<endl;
				 printCurrentLine($$);
				 
		table->printAllScopeTable(logout);
		table->exitScope();
				 }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
	 
	
   if($1->getType()=="VOID"){ errorCount++;
	   logout<<"Error at line no : "<<line_count<<" Variable type cannot be void"<<endl;
	   errorOut<<"Error at line no : "<<line_count<<" Variable type cannot be void"<<endl;
   }
	cout<<"var_declaration : type_specifier declaration_list SEMICOLON"<<endl;
	logout<<"line no : "<<line_count<<" var_declaration : type_specifier declaration_list SEMICOLON"<<endl;
  $$=new hp();$$->push($1);
	 for(int i=0;i<$2->size();i++){
		 if($2->at(i)->getType()=="ID"){
			 symbolInfo *temp=table->searchSymbol($2->at(i)->getName());
			 if(temp->getTypeSpecifier()==""){
				if($1->getType()=="VOID"){
					temp->setTypeSpecifier("INT");//for preventing further errors
				}
     temp->setTypeSpecifier($1->getType());
	 }
	 }
	 $$->push($2->at(i));
	 }
	$$->push($3);
	printCurrentLine($$);
	
	


	}
 		 ;
 		 
type_specifier	: INT {
	  
           cout<<"type_specifier	: INT"<<endl;
			logout << "line no :" <<line_count<<  ": type_specifier :  INT"<<endl;
			
			$$=$1;
			logout<<$1->getName()<<endl;
		
			
		}
 		| FLOAT {
			 cout<<"type_specifier	: FLOAT"<<endl;
			
			logout << "line no :" <<line_count<<  ": type_specifier :  FLOAT"<<endl;
			
			$$=$1;
			logout<<$1->getName()<<endl;
			
			}
 		| VOID {cout<<"type_specifier	: VOID"<<endl;
		  
			logout << "line no :" <<line_count<<  ": type_specifier :  VOID"<<endl;
			
		$$=$1;
			logout<<$1->getName()<<endl;
				
			}
 		;
 		
declaration_list : declaration_list COMMA ID {

	cout<<"declaration_list : declaration_list COMMA ID"<<endl;
	logout<<"Line no : "<<line_count<<" declaration_list : declaration_list COMMA ID"<<endl;
	$$=new hp();
	         for(int i=0;i<$1->size();i++){
				 $$->push($1->at(i));
			 }
			  $$->push($2);
			  //assemblyCode
	
			 symbolInfo* inserted= table->searchSymbol($3->getName());
			  if(inserted==nullptr){
				  if(currentScopeId()=="1"){
		//this is the global scope, save this on the globalVaribales
		
			
                       	globalVaribales.push_back($3->getName());
						     table->insertNewSymbol($3->getName(),"ID",logout);
						   asmOut<<$3->getName()<<"\tDW\t?"<<endl;
			 
	


	} else
	{ SP_VAL+=2;
				  table->insertNewSymbol($3->getName(),"ID",logout);
				  symbolInfo* temp=table->searchSymbol($3->getName());
				  temp->setStackOffset(-(SP_VAL));
				  asmOut<<"\tSUB SP,2"<<endl;
				  }
				  
				  
				  
			  }
			  else{ errorCount++;
				  logout<<"Error at line "<<line_count<<" Multiple declaration of "<<$3->getName()<<endl;
				   errorOut<<"Error at line "<<line_count<<" Multiple declaration of "<<$3->getName()<<endl;
			  }
			  $$->push($3);
	              printCurrentLine($$);
	}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
                         //a[7],set setVariableType "array type" here

			   cout<<"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl;
			   logout<<"Line no : "<<line_count<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl;
			   $$=new hp();
			   for(int i=0;i<$1->size();i++){
				   $$->push($1->at(i));
			   }
			   $$->push($2);
			   $$->push($3);
			   symbolInfo* inserted=table->searchSymbol($3->getName());
			   if(inserted==nullptr){
				   //hasn't been inserted before
				   if(currentScopeId()=="1"){
                 table->insertNewSymbol($3->getName(),"ID",logout);
				   symbolInfo* tempSymbol=table->lookUpSymbol($3->getName());
				   tempSymbol->setVariableType("array");
				      tempSymbol->setVarSize(stoi($5->getName()));
				   asmOut<<$3->getName()<<"\tDW\t"<<$5->getName()<<"\tDUP(?)"<<endl;

				   }
				   else{
					     SP_VAL=SP_VAL+stoi($5->getName())*2;
				   table->insertNewSymbol($3->getName(),"ID",logout);
				   symbolInfo* tempSymbol=table->lookUpSymbol($3->getName());
				   tempSymbol->setVariableType("array");
				   tempSymbol->setStackOffset(-(SP_VAL));
				   tempSymbol->setVarSize(stoi($5->getName()));
				    asmOut<<"\tSUB SP,"<<SP_VAL<<endl;
				  
				  
				   }
				  

				   
			   }
			   else{
                         logout<<"Error at line : "<<line_count<<" Multiple declaration of "<<$3->getName()<<endl;
						 errorOut<<"Error at line : "<<line_count<<" Multiple declaration of "<<$3->getName()<<endl;   
			errorCount++;   }
			   $$->push($4);
			  $$->push($5);
			   $$->push($6);
			   printCurrentLine($$);

			   }
		  | ID {
                 $$=new hp();
			 
			  cout<<"declaration_list : ID"<<$1->getName()<<" id name end"<<endl;
			  logout<<"line no "<<line_count<<" declaration_list : ID "<<endl;
			   symbolInfo* inserted=table->searchSymbol($1->getName());
			  if(inserted==nullptr){
				  if(currentScopeId()=="1"){
					  table->insertNewSymbol($1->getName(),"ID",logout);
					  asmOut<<$1->getName()<<"\tDW\t?"<<endl;
				  }
				  else{
					  SP_VAL+=2;
				  table->insertNewSymbol($1->getName(),"ID",logout);
				  symbolInfo *temp=table->lookUpSymbol($1->getName());
				  temp->setStackOffset(-(SP_VAL));
				   asmOut<<"\tSUB SP,2"<<endl;
				  }
				  
				  
				  
			  }
			  else{errorCount++;
				  logout<<"Error at line "<<line_count<<" multiple declaration of "<<$1->getName()<<endl;
				   errorOut<<"Error at line "<<line_count<<" multiple declaration of "<<$1->getName()<<endl;
			  }
			  $$->push($1);
			   printCurrentLine($$);
		
		   $$->setVarType($1->getType());	
		  
		  } 
 		  | ID LTHIRD CONST_INT RTHIRD {
			   
			   //setVariableType array here a[n]
			   $$=new hp();
			   cout<<"declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl;
			    logout<<"Line no :"<<line_count<<" declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl;
				

			   $$->push($1);
			   bool inserted=table->insertNewSymbol($1->getName(),"ID",logout);
			   if(inserted){
				   //hasn't been inserted before
				   
				   symbolInfo* tempSymbol=table->lookUpSymbol($1->getName());
				   tempSymbol->setVariableType("array");
				   if(currentScopeId()=="1"){
					  
				      tempSymbol->setVarSize(stoi($3->getName()));
				   asmOut<<$3->getName()<<"\tDW\t"<<$3->getName()<<"\tDUP(?)"<<endl;

				   }
				   else{
              SP_VAL=SP_VAL+stoi($3->getName())*2;
				  
				 
				   tempSymbol->setStackOffset(-(SP_VAL));
				   tempSymbol->setVarSize(stoi($3->getName()));
				    asmOut<<"\tSUB SP,"<<SP_VAL<<endl;
				  
				   }

				  

				   
			   }
			   else{
                         logout<<"Error at line : "<<line_count<<" Multiple declaration of "<<$1->getName()<<endl;
						 errorOut<<"Error at line : "<<line_count<<" Multiple declaration of "<<$1->getName()<<endl;   
			  errorCount++; }

			   $$->push($2);
			  $$->push($3);
			   $$->push($4);
			    printCurrentLine($$);
			   
			   }
 		  ;
 		  
statements : statement { 
	$$=new hp();
	cout<<"statements : statement"<<endl;
	logout<<"Line no : "<<line_count<<" statements : statement"<<endl;
	for(int i=0;i<$1->size();i++){
		$$->push($1->at(i));
		

	}
 printCurrentLine($$);

	}
	   | statements statement {
		   $$=new hp();
		   cout<<"statements :statements statement"<<endl;
		   logout<<"Line no : "<<line_count<<" statements :statements statement"<<endl;
for(int i=0;i<$1->size();i++){
		$$->push($1->at(i));
		

	}for(int i=0;i<$2->size();i++){
		$$->push($2->at(i));
		

	}
		    printCurrentLine($$);
		   
		   }
		   
	   ;
	   
statement : func_declaration {
	$$=new hp();
	for(int i=0;i<$1->size();i++){
		$$->push($1->at(i));
	}
	errorCount++;
              logout<<"Error at Line no : "<<line_count<<" Invalid function declaration inside another function"<<endl;
			   errorOut<<"Error at Line no : "<<line_count<<" Invalid function declaration inside another function"<<endl;
 printCurrentLine($$);
 }     |func_definition{
	 $$=new hp();
	for(int i=0;i<$1->size();i++){
		$$->push($1->at(i));
	}
	errorCount++;
              logout<<"Error at Line no : "<<line_count<<" Invalid function definition inside another function"<<endl;
			   errorOut<<"Error at Line no : "<<line_count<<" Invalid function definition inside another function"<<endl;
printCurrentLine($$);
}
      | var_declaration {
	cout<<"statement : var_declaration"<<endl;
	logout << "line no: "<<line_count <<  " statement : var_declaration"<<endl;
	$$=new hp();
			for(int i=0;i<$1->size();i++){
				$$->push($1->at(i));
			}printCurrentLine($$);}
	  | expression_statement {
		  cout<<"statement : expression_statement"<<endl;
		  logout << "line no: "<<line_count <<  " statement : expression_statement"<<endl;
		  	$$=new hp();
			for(int i=0;i<$1->size();i++){
				$$->push($1->at(i));
			}printCurrentLine($$);}
	  | compound_statement {cout<<"statement : compound_statement"<<endl;
	  logout << "line no: "<<line_count <<  " statement : compound_statement"<<endl;
	  	$$=new hp();
			for(int i=0;i<$1->size();i++){
				$$->push($1->at(i));
			}printCurrentLine($$);}
	  | FOR LPAREN expression_statement { 
		  start=createNewLabel();
		  asmOut<<start<<" :"<<endl;
	  } expression_statement { ext=createNewLabel(); stmt=createNewLabel(); eval=createNewLabel();
		  asmOut<<"\tCMP CX, 0"<<endl;
	                        asmOut<<"JE "<<ext<<endl;
							asmOut<<"JMP "<<stmt<<endl;   
							asmOut<<eval<<" : "<<endl;
	  } expression { asmOut<<" JMP "<<start<<endl;
		  asmOut<<stmt<<" : "<<endl;
	  } RPAREN statement {
		 
		  asmOut<<"JMP "<<eval<<endl;
		  asmOut<<ext<<" :"<<endl;

		  cout<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl;
		  logout << "line no: "<<line_count <<  " statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl;
		 $$=new hp(); $$->push($1);$$->push($2);
		 
			for(int i=0;i<$3->size();i++)
				$$->push($3->at(i));

				for(int i=0;i<$5->size();i++)
				$$->push($5->at(i));
				for(int i=0;i<$7->size();i++)
				$$->push($7->at(i)); 
				$$->push($9);
				for(int i=0;i<$10->size();i++)
				$$->push($10->at(i));
			printCurrentLine($$); 
			}
	  |if_statement  statement %prec LOWER_THAN_ELSE {
		
		  asmOut<<elseStatement<<" :"<<endl;
		  

		

		
		  cout<<"statement : IF LPAREN expression RPAREN statement"<<endl;
		  logout << "line no: "<<line_count <<  " statement : IF LPAREN expression RPAREN statement"<<endl;
		   $$=new hp(); 
		
			for(int i=0;i<$1->size();i++)
				$$->push($1->at(i)); 
				for(int i=0;i<$2->size();i++)
				$$->push($2->at(i));
				
			printCurrentLine($$);
		  }
	  | if_statement statement ELSE {
		  IfEndStatment= createNewLabel();;
		
		asmOut<<"JMP "<<IfEndStatment<<endl;
	
		asmOut<<elseStatement<<" :"<<endl;

	  } statement {
		  
		  asmOut<<IfEndStatment<<" :"<<endl;
		  cout<<"statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl;
		  logout << "line no: "<<line_count <<  " statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl;
		  $$=new hp(); 
		 
			for(int i=0;i<$1->size();i++)
				$$->push($1->at(i)); 
				for(int i=0;i<$2->size();i++)
				$$->push($2->at(i)); $$->push($3);
			  for(int i=0;i<$5->size();i++)
				$$->push($5->at(i)); 	printCurrentLine($$);
		  }
	  | WHILE LPAREN {  WhileStart=createNewLabel(); WhileExt=createNewLabel();
	      asmOut<<WhileStart<<" : " <<endl;
           asmOut<<"CMP CX,0"<<endl;
		   asmOut<<"JE "<<WhileExt<<endl;
	   } expression RPAREN statement {
		   asmOut<<"\tJMP  "<<WhileStart<<endl;
		   asmOut<<WhileExt<<" : "<<endl;
		  cout<<"statement : WHILE LPAREN expression RPAREN statement"<<endl;
		  logout << "line no: "<<line_count <<  " statement : WHILE LPAREN expression RPAREN statement"<<endl;
		  $$=new hp(); $$->push($1);$$->push($2);
		 
			for(int i=0;i<$4->size();i++)
				$$->push($4->at(i)); $$->push($5);
				for(int i=0;i<$6->size();i++)
				$$->push($6->at(i));
				
			printCurrentLine($$);}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
		  cout<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl;
		  logout << "line no: "<<line_count <<  " statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl;
		  $$=new hp(); $$->push($1);$$->push($2);
		 
			
				$$->push($3);
				if(table->lookUpSymbol($3->getName())==nullptr){ errorCount++;
					logout<<"Error at Line no : "<<line_count<<" undeclared variable "<<$3->getName()<<endl;
					errorOut<<"Error at Line no : "<<line_count<<" undeclared variable "<<$3->getName()<<endl;
				}
				 $$->push($4);$$->push($5);
			

				 asmOut<<"\tMOV AX ,"<<getVariable(table->lookUpSymbol($3->getName()))<<endl;
				  asmOut<<"MOV FOR_PRINT,AX\n";
				 asmOut<<"CALL PRINTLN"<<endl;
				
				
			printCurrentLine($$);
			}
	  | RETURN expression SEMICOLON {
		  cout<<"statement : RETURN expression SEMICOLON"<<endl;
		  logout << "line no: "<<line_count <<  " statement : RETURN expression SEMICOLON"<<endl;
		   $$=new hp(); $$->push($1);
		 
			for(int i=0;i<$2->size();i++)
				$$->push($2->at(i));
				
				$$->push($3);
				printCurrentLine($$);
				//assemblyCode
				asmOut<<"POP CX"<<endl;
			
				}
			
	  ;
if_statement : IF LPAREN expression RPAREN {
		  elseStatement= createNewLabel();
		asmOut<<"\tPOP AX"<<endl;
		asmOut<<"CMP AX,0 "<<endl;
		asmOut<<"JE "<<elseStatement<<endl;
		$$=new hp(); $$->push($1); $$->push($2);
		for(int i=0;i<$3->size();i++){
			$$->push($3->at(i));
		} 
		$$->push($4);
		printCurrentLine($$);
	  }	  
  
	  
expression_statement 	: SEMICOLON		{
	                cout<<"expression_statement 	: SEMICOLON"<<endl;
                    logout << "line no: "<<line_count <<  " expression_statement 	: SEMICOLON"<<endl;
					$$=new hp();
					$$->push($1);
					printCurrentLine($$);
}	
			| expression SEMICOLON {
				cout<<"expression_statement 	: expression SEMICOLON"<<endl;
				 logout << "line no: "<<line_count <<  " expression_statement 	: expression SEMICOLON"<<endl;
			$$=new hp();
			for(int i=0;i<$1->size();i++){
				$$->push($1->at(i));
			}
					$$->push($2);
					printCurrentLine($$);	 
					 asmOut<<"\tPOP CX"<<endl;
				 }

			;
	  
variable : ID 	
      {    //now you have to check if it doesn't exit, you can't use it here
	      
		 
		logout << "line no: "<<line_count <<  " variable : ID"<<endl;
         
          cout<<"variable : ID"<<endl;
		//check if it's been inserted before
		 $$ = new hp();
		 symbolInfo* temp=table->lookUpSymbol($1->getName());
		if(temp==nullptr){ errorCount++;
			logout<<"Error at line no : "<<line_count<<" undeclared variable "<<$1->getName()<<endl;
			errorOut<<"Error at line no : "<<line_count<<" undeclared variable "<<$1->getName()<<endl;
		//NO ID EXITS WITH THIS,JUST PASS INT
		$$->setVarType("INT");
		
		}
		else{
			if(temp->getVariableType()=="array" || temp->getVariableType()=="func"){ errorCount++;
				logout<<"Error at Line no : "<<line_count<<" Type mismatch, "<<temp->getName()<<" is an "<<temp->getVariableType()<<endl;
				errorOut<<"Error at Line no : "<<line_count<<" Type mismatch, "<<temp->getName()<<" is an "<<temp->getVariableType()<<endl;
			}
			if(temp->getTypeSpecifier()==""){
			temp->setTypeSpecifier("INT"); ////forceably setting all undeclared variable to int
		}
		$$->setVarType(temp->getTypeSpecifier());
		}
		

		$$->push($1);
		
		printCurrentLine($$);
		//assemblyCode
		asmOut<<"\tMOV CX,"<<	getVariable(table->lookUpSymbol($1->getName()))<<endl;
					 asmOut<<"\tPUSH CX"<<endl;
		
		
 }	
	 | ID LTHIRD expression RTHIRD  {
		 //a[1]
		 //check if the index isn't negative or float here
		 //check if the id is array here
		 //if poss

		 cout<<"variable : ID LTHIRD expression RTHIRD"<<endl;
		 logout<<"Line no : "<<line_count<<" variable : ID LTHIRD expression RTHIRD"<<endl;
		 $$ = new hp();
		if(table->lookUpSymbol($1->getName())==nullptr){ errorCount++;
			logout<<"Error at line no : "<<line_count<<" undeclared variable "<<$1->getName()<<endl;
			errorOut<<"Error at line no : "<<line_count<<" undeclared variable "<<$1->getName()<<endl;
		}
		else{ 
			if(table->lookUpSymbol($1->getName())->getVariableType()!="array"){ errorCount++;
				logout<<"Error at line no : "<<line_count<<" " <<$1->getName()<<" not an array "<<endl;
				errorOut<<"Error at line no : "<<line_count<<" " <<$1->getName()<<" not an array "<<endl;
			}
		}
		

		$$->push($1);
		if($1->getTypeSpecifier()==""){
			$1->setTypeSpecifier("INT"); //forceably setting all undeclared variable to int
		}
		$$->setVarType($1->getTypeSpecifier());
		$$->push($2);
		for(int i=0;i<$3->size();i++){
			$$->push($3->at(i));
		}
		if($3->getVarType()!="INT"){errorCount++;
		logout<<"Error at line no : "<<line_count<<" Expression inside third brackets not an integer"<<endl;
			errorOut<<"Error at line no : "<<line_count<<" Expression inside third brackets not an integer"<<endl;}
		$$->push($4);
		printCurrentLine($$);
		 }
	 ;
	 
 expression : logic_expression	{cout<<"expression : logic_expression"<<endl;
 logout<<"Line no : "<<line_count<<" expression : logic_expression"<<endl;
             $$=new hp();
			 for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				}
				$$->setVarType($1->getVarType());
			 
			 printCurrentLine($$);
 }
	   | variable ASSIGNOP logic_expression {
		   cout<<"expression : variable ASSIGNOP logic_expression"<<endl;
		   logout<<"Line no : "<<line_count<<" expression : variable ASSIGNOP logic_expression"<<endl;
		   $$=new hp();
			 for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));}
				$$->push($2);
				for(int i=0;i<$3->size();i++){
					
					$$->push($3->at(i));}
				if( printVoidFunctionError($1->getVarType(),$3->getVarType()));
				else if($1->getVarType()!=$3->getVarType() && !($1->getVarType()=="FLOAT" && $3->getVarType()=="INT")){
					 errorCount++;
					
					logout<<"Error at line no : "<<line_count<<" Type Mismatch"<<endl;
					errorOut<<"Error at line no : "<<line_count<<"  Type Mismatch"<<endl;
				} printCurrentLine($$);
				//different for variable and array
	 asmOut<<"\tPOP CX"<<endl;
	asmOut<<"\tMOV "<<getVariable( table->lookUpSymbol($1->at(0)->getName()))<<", CX"<<endl;
	asmOut<<"\tPUSH CX"<<endl;		   }	
	   ;
			
logic_expression : rel_expression 	{
	cout<<"logic_expression : rel_expression"<<endl;
	logout<<"Line no : "<<line_count<<" logic_expression : rel_expression"<<endl;
	$$=new hp();
			 for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				}
				$$->setVarType($1->getVarType());
			 
			 printCurrentLine($$);;
	}
		 | rel_expression LOGICOP rel_expression 	{
			 cout<<"logic_expression : rel_expression LOGICOP rel_expression"<<endl;
			 logout<<"Line no : "<<line_count<<" logic_expression : rel_expression LOGICOP rel_expression"<<endl;
			 $$=new hp();
			 for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				}
				$$->push($2);
				for(int i=0;i<$3->size();i++){
					
					$$->push($3->at(i));

				}$$->setVarType("INT"); printVoidFunctionError($1->getVarType(),$3->getVarType());
			  printCurrentLine($$);
			asmOut<<"\tPOP CX"<<endl;
			asmOut<<"\tPOP AX"<<endl;
			asmOut<<"\tCMP AX,CX"<<endl;
			string relopTrue=createNewLabel();
			string relopFalse=createNewLabel();
			
			 if($2->getName()=="&&"){
				
			asmOut<<"CMP AX,0"<<endl;
			asmOut<<"JE "<<relopFalse<<endl;
			asmOut<<"CMP CX, 0"<<endl;
			asmOut<<"JE "<<relopFalse<<endl;
			asmOut<<"PUSH 1"<<endl;
			asmOut<<"JMP "<<relopTrue<<endl;
			asmOut<<relopFalse<<" :"<<endl;
			asmOut<<"PUSH 0"<<endl;
			asmOut<<relopTrue<<" : "<<endl;
			 
			} else if($2->getName()=="||"){
				
			asmOut<<"CMP AX,0"<<endl;
			asmOut<<"JNE "<<relopFalse<<endl;
			asmOut<<"CMP CX, 0"<<endl;
			asmOut<<"JNE "<<relopFalse<<endl;
			asmOut<<"PUSH 0"<<endl;
			asmOut<<"JMP "<<relopTrue<<endl;
			asmOut<<relopFalse<<" :"<<endl;
			asmOut<<"PUSH 1"<<endl;
			asmOut<<relopTrue<<" : "<<endl;
			
			
			} 
			 }
		 ;
			
rel_expression	: simple_expression {cout<<"rel_expression	: simple_expression"<<endl;
             logout<<"Line no : "<<line_count<<" rel_expression	: simple_expression"<<endl;
			 $$=new hp();
			 for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				}
				$$->setVarType($1->getVarType());
			 
			 printCurrentLine($$); ;
			 
}
		| simple_expression RELOP simple_expression	{
			cout<<"rel_expression	: simple_expression RELOP simple_expression"<<endl;
			logout<<"Line no : "<<line_count<<" rel_expression	: simple_expression RELOP simple_expression"<<endl;
			$$=new hp();
			 for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				}
				$$->push($2);
				for(int i=0;i<$3->size();i++){
					
					$$->push($3->at(i));

				}$$->setVarType("INT"); printVoidFunctionError($1->getVarType(),$3->getVarType());
			 
			 printCurrentLine($$); ;

			asmOut<<"\tPOP CX"<<endl;
			asmOut<<"\tPOP AX"<<endl;
			asmOut<<"\tCMP AX,CX"<<endl;
			
			string relopTrue=createNewLabel();
			string relopFalse=createNewLabel();
			
			if($2->getName()=="<"){
				asmOut<<"JNL "<<relopFalse<<endl<<"PUSH 1 "<<endl<<"JMP "<<relopTrue<<endl;
				asmOut<<relopFalse<<" : \nPUSH 0 "<<endl<<relopTrue<<" :"<<endl;
			
			} else if($2->getName()=="<="){
				asmOut<<"JNLE "<<relopFalse<<endl<<"PUSH 1 "<<endl<<"JMP "<<relopTrue<<endl;
				asmOut<<relopFalse<<" : \nPUSH 0 "<<endl<<relopTrue<<" :"<<endl;
				
			} else if($2->getName()==">"){
				asmOut<<"JNG "<<relopFalse<<endl<<"PUSH 1 "<<endl<<"JMP "<<relopTrue<<endl;
				asmOut<<relopFalse<<"\nPUSH 0 "<<endl<<relopTrue<<" :"<<endl;
				
		
			} else if($2->getName()==">="){
				asmOut<<"JNGE "<<relopFalse<<endl<<"PUSH 1 "<<endl<<"JMP "<<relopTrue<<endl;
				asmOut<<relopFalse<<"\nPUSH 0 "<<endl<<relopTrue<<" :"<<endl;
				
			
			} else if($2->getName()=="=="){
				asmOut<<"JNE "<<relopFalse<<endl<<"PUSH 1 "<<endl<<"JMP "<<relopTrue<<endl;
				asmOut<<relopFalse<<" : \nPUSH 0 "<<endl<<relopTrue<<" :"<<endl;
			
			
			} else if($2->getName()=="!="){
				asmOut<<"JE "<<relopFalse<<endl<<"PUSH 1 "<<endl<<"JMP "<<relopTrue<<endl;
				asmOut<<relopFalse<<": \nPUSH 0 "<<endl<<relopTrue<<" :"<<endl;
				
							
			}
			}
		;
				
simple_expression : term {cout<<"simple_expression : term"<<endl;
    logout<<"Line no : "<<line_count<<" simple_expression : term"<<endl;
	$$=new hp();
			 for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				}
				$$->setVarType($1->getVarType());
			 
			 printCurrentLine($$); 
			 //assemblyCode
			
			 

}
		  | simple_expression ADDOP term {cout<<"simple_expression : simple_expression ADDOP term "<<endl;
		   logout<<"Line no : "<<line_count<<" simple_expression : simple_expression ADDOP term"<<endl;
		   $$=new hp();
			 for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				}
				$$->push($2);
				for(int i=0;i<$3->size();i++){
					
					$$->push($3->at(i));

				}
				printVoidFunctionError($1->getVarType(),$3->getVarType());
				
				if($1->getVarType()=="FLOAT" || $3->getVarType()=="FLOAT")
			 $$->setVarType("FLOAT");
			 else $$->setVarType("INT");

				printCurrentLine($$); 
				//assemblyCode

				if($2->getName()=="+"){
				
			
					 asmOut<<"\tPOP CX"<<endl;
				
			
				 asmOut<<"\tPOP AX"<<endl;
				  asmOut<<"\tADD AX,CX"<<endl;
				   asmOut<<"\tMOV CX,AX"<<endl;
				    asmOut<<"\tPUSH CX"<<endl;}
					else{
						   asmOut<<"\tPOP CX"<<endl;
				
			
				 asmOut<<"\tPOP AX"<<endl;
				  asmOut<<"\tSUB AX,CX"<<endl;
				   asmOut<<"\tMOV CX,AX"<<endl;
				    asmOut<<"\tPUSH CX"<<endl;
					}
		  }
		  ;
					
term :	unary_expression {cout<<"term :	unary_expression"<<endl;
logout<<"Line no : "<<line_count<<" term :	unary_expression"<<endl;
              $$=new hp();
			 for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				}
				$$->setVarType($1->getVarType());
			 
			 printCurrentLine($$); ;

}

     |  term MULOP unary_expression {
		 
		 cout<<"term :term MULOP unary_expression"<<endl;
		 logout<<"Line no: "<<line_count<<" term :term MULOP unary_expression"<<endl;
		 $$=new hp();
		 printVoidFunctionError($1->getVarType(),$3->getVarType());
		 int x=0;bool singleZero=false;
		 if($3->size()==1 && $3->at(0)->getType()!="ID"){
			 singleZero=true;
		  stringstream num($3->at(0)->getName());
		  num >> x; }
	
	for(int i=0;i<$1->size();i++){ 
		$$->push($1->at(i));
	}$$->push($2);
	for(int i=0;i<$3->size();i++){
		$$->push($3->at(i));
	}
		 if($2->getName()=="%"){
             if($1->getVarType()!="INT" || $3->getVarType()!="INT"){ errorCount++;
				 logout<<"Error at line no : "<<line_count<<"  Non-Integer operand on modulus operator"<<endl;
				 errorOut<<"Error at line no : "<<line_count<<"  Non-Integer operand on modulus operator"<<endl;
			 }
			  if(singleZero && x==0){ errorCount++;
                         logout<<"Error at line no : "<<line_count<<"  Modulus by Zero"<<endl;
						  errorOut<<"Error at line no : "<<line_count<<"  Modulus by Zero"<<endl;
			 }
			 $$->setVarType("INT");
		 }
		else if($2->getName()=="*"){
             if($1->getVarType()=="FLOAT" || $3->getVarType()=="FLOAT")
			 $$->setVarType("FLOAT");
			 else $$->setVarType("INT");
		 }
		 else{ if(singleZero && x==0){ errorCount++;
                         logout<<"Error at line no : "<<line_count<<"  Divide by Zero"<<endl;
						  errorOut<<"Error at line no : "<<line_count<<"  Divide by Zero"<<endl;
			 }
			  $$->setVarType("FLOAT");
		 }
		 if($2->getName()=="%"){
 
          asmOut<< "POP CX"<<endl;
			 asmOut<< "POP AX"<<endl;
			  asmOut<<"IDIV CX"<<endl;
			  asmOut<<"PUSH DX" <<endl;
		 
		 }
		 else if($2->getName()=="/"){
			 asmOut<< "POP CX"<<endl;
			 asmOut<< "POP AX"<<endl;
			  asmOut<<"IDIV CX"<<endl;
			  asmOut<<"PUSH AX" <<endl;
			  

		 }
		else { //for multiplication
					
					 asmOut<<"\tPOP CX"<<endl;
				
				
				 asmOut<<"\tPOP AX"<<endl;
				  asmOut<<"\tIMUL CX"<<endl;
				   asmOut<<"\tMOV CX,AX"<<endl;
				    asmOut<<"\tPUSH CX"<<endl;
		}
		 }
     ;

unary_expression : ADDOP unary_expression  {
	cout<<"unary_expression : ADDOP unary_expression"<<endl;
	logout<<"Line no : "<<line_count<<" "<<endl;
	$$=new hp();
	$$->push($1);
	for(int i=0;i<$2->size();i++){
		$$->push($2->at(i));
	}
	$$->setVarType($2->getVarType());
	printCurrentLine($$); printVoidFunctionError("",$2->getVarType());
	if($1->getName()=="-"){
				
				asmOut<< "POP CX\nNEG CX \nPUSH CX\n";
			}
  ;
	}
		 | NOT unary_expression {
			 cout<<"unary_expression : NOT unary_expression"<<endl;
			 logout<<"Line no : "<<line_count<<" unary_expression : NOT unary_expression"<<endl;
			 $$=new hp();
			 $$->push($1);
	    for(int i=0;i<$2->size();i++){
		$$->push($2->at(i));
		$$->setVarType($2->getVarType()); printVoidFunctionError("",$2->getVarType());
		string TrueLabel=createNewLabel();
			string FalseLabel=createNewLabel();
			asmOut<< "POP CX"<<endl;
			asmOut<<"CMP CX, 0"<<endl; 
			asmOut<<"JNE "<<TrueLabel<<endl;
			asmOut<<"MOV CX, 1"<<endl;
			asmOut<<"JMP "<<FalseLabel<<endl;
			asmOut<<TrueLabel<<" : "<<endl;
			asmOut<<"MOV CX,0"<<endl;
			asmOut<<FalseLabel<<" : "<<endl;
			asmOut<<"PUSH CX"<<endl;

			
	}
	printCurrentLine($$); ;
			 }
		 | factor {
			 cout<<"unary_expression : factor"<<endl;
			 logout<<"Line no : "<<line_count<<" unary_expression : factor"<<endl;
			 $$=new hp();
			 for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				}
				$$->setVarType($1->getVarType());
			 
			 printCurrentLine($$);;
			 }
		 ;
	
factor	: variable {
       
	cout<<"factor	: variable"<<endl;
	logout<<"line no : "<<line_count<<" factor	: variable"<<endl;
	  $$ = new hp();
	  for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				}
				$$->setVarType($1->getVarType());
				if($1->getVarType()=="VOID"){ errorCount++;
							logout<<"Error at line no : "<<line_count<<" A void type variable cannot be called as a part of an expression"<<endl;
							errorOut<<"Error at line no : "<<line_count<<" A void type variable cannot be called as a part of an expression"<<endl;
						} printCurrentLine($$);
;

	}
	| ID LPAREN argument_list RPAREN {
		//foo(a,b)
		cout<<"factor	:  ID LPAREN argument_list RPAREN"<<endl;
		//this is a function call, so you have to check 
		// 1.if it has been declared before and 
		//2.if the parameters match
		//3.don't have to check return type,right? cause that's gonna be done in ASSIGNOP
        $$=new hp();
		$$->push($1);$$->push($2);
		for(int i=0;i<$3->size();i++){
			$$->push($3->at(i));
		}$$->push($4);
       symbolInfo* symbol;
        symbol=table->lookUpSymbol($1->getName());
		if(symbol==nullptr){ errorCount++;
         logout<<"Error at line no : "<<line_count<<" undeclared variable "<<$1->getName()<<endl;
		   errorOut<<"Error at line no : "<<line_count<<" undeclared variable "<<$1->getName()<<endl;
		   $$->setVarType("INT"); //to prevent further errors
		}else{
			
                    if(symbol->getVariableType()=="func"){
						//if(symbol->getReturnType()=="VOID"){ errorCount++;
						//	logout<<"Error at line no : "<<line_count<<" A void function cannot be called as a part of an expression"<<endl;
							//errorOut<<"Error at line no : "<<line_count<<" A void function cannot be called as a part of an expression"<<endl;
						//}
						//check for argument_list $3
						vector<pair<string,string>> params=symbol->getParameters();
						if(params.size()!=arglist.size()){errorCount++;
	                        errorOut<<"Error at line no : "<<line_count<<" Total number of arguments mismatch with declaration in function "<<symbol->getName()<<endl;					
							logout<<"Error at line no : "<<line_count<<" Total number of arguments mismatch with declaration in function "<<symbol->getName()<<endl;
						}else{
						for(int i=0;i<params.size();i++){ 
							if(params.at(i).first!=arglist.at(i)){errorCount++;
							
								logout<<"Error at line no : "<<line_count<<" "<<i<<"th argument mismatch in function func "<<symbol->getName()<<endl;
								errorOut<<"Error at line no : "<<line_count<<" "<<i<<"th argument mismatch in function func "<<symbol->getName()<<endl;
							}
						}
						}
						

					}
					else{ errorCount++;
						  logout<<"Error at line no : "<<line_count<<" "<<$1->getName()<<" is not a function "<<symbol->getVariableType()<<endl;
						  errorOut<<"Error at line no : "<<line_count<<" "<<$1->getName()<<" is not a function"<<symbol->getVariableType()<<endl;
					}
	$$->setVarType(symbol->getReturnType());	}
		
		


        printCurrentLine($$);
 
       asmOut<<"CALL "<<$1->getName()<<endl;
	   asmOut<<"PUSH CX"<<endl;
     
      arglist.clear();

		}
	| LPAREN expression RPAREN {
	 //(a+b)
		cout<<"factor :LPAREN expression RPAREN"<<endl;
		logout<<"Line no : "<<line_count<<" factor :LPAREN expression RPAREN"<<endl;
		$$=new hp(); $$->push($1);
		for(int i=0;i<$2->size();i++){
					
					$$->push($2->at(i));

				} $$->push($3);
		$$->setVarType($2->getVarType()); printCurrentLine($$); 
		}
	| CONST_INT {
		$$=new hp();
		$$->push($1);
		$$->setVarType("INT");
		cout<<"factor : CONST_INT "<<endl;
		logout<<"Line no : "<<line_count<<" factor : CONST_INT "<<endl; printCurrentLine($$); ;
		asmOut<<"\tMOV CX,"<<$1->getName()<<endl;
		asmOut<<"PUSH CX"<<endl;
		}
	| CONST_FLOAT {
		$$=new hp();
		$$->push($1);
		$$->setVarType("FLOAT");
		cout<<"factor :CONST_FLOAT"<<endl;
		logout<<"Line no : "<<line_count<<" factor :CONST_FLOAT"<<endl; printCurrentLine($$); ;
		asmOut<<"\tMOV CX,"<<$1->getName()<<endl;
		}
	| variable INCOP {
		$$=new hp();
		for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				} $$->push($2);
		$$->setVarType($1->getVarType());
		cout<<"factor :variable INCOP "<<endl;
		logout<<"Line no : "<<line_count<<" factor :variable INCOP"<<endl; printCurrentLine($$); ;
	
		asmOut<<"\tMOV AX,1"<<endl;
		asmOut<<"\tADD "<<getVariable(table->lookUpSymbol($1->at(0)->getName()))<<", AX"<<endl;
		
		}
	| variable DECOP {
		$$=new hp();
		for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				} $$->push($2);
		$$->setVarType($1->getVarType());
		cout<<"factor : variable DECOP"<<endl;
		logout<<"Line no : "<<line_count<<" factor : variable DECOP"<<endl; printCurrentLine($$);
	asmOut<<"\tMOV AX,1"<<endl;
		asmOut<<"\tSUB "<<getVariable(table->lookUpSymbol($1->at(0)->getName()))<<", AX"<<endl;
		}
	;
	
argument_list : arguments {cout<<"argument_list : arguments"<<endl;
                     cout<<"argument_list : arguments"<<endl;
					 logout<<"Line no :"<<line_count<<" argument_list : arguments"<<endl;
                     
                  $$ = new hp();
				 
				for(int i=0;i<$1->size();i++){
				
					$$->push($1->at(i));

				} printCurrentLine($$);
}
			  | {   $$=new hp();
			  //eikhane argument list ekbaro empty diye check kori nai, $$=new hp(); eita likhte bhule gesilam
			       
				  cout<<"argument_list : empty "<<endl;}
			  ;
	
arguments : arguments COMMA logic_expression {
	cout<<" arguments : arguments COMMA logic_expression "<<endl;
                $$ = new hp();
                logout<<"line no :"<<line_count<<" arguments : arguments COMMA logic_expression "<<endl;
				for(int i=0;i<$1->size();i++){
				
					$$->push($1->at(i));

				}
				$$->push($2);
				for(int i=0;i<$3->size();i++){
				
					$$->push($3->at(i));

				}arglist.push_back($3->getVarType()); 
				printCurrentLine($$);


                
}
	      | logic_expression {
			  cout<<"arguments : logic_expression"<<endl;
			  logout<<"line no :"<<line_count<<" arguments : arguments : logic_expression"<<endl;
			  $$ = new hp();
			  for(int i=0;i<$1->size();i++){
					
					$$->push($1->at(i));

				}
				arglist.push_back($1->getVarType());
				 printCurrentLine($$);
		  }
	      ;
 

%%
int main(int argc,char *argv[])
{
     FILE *fp=fopen(argv[1],"r");
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	logout.open("1805110log.txt");
	errorOut.open("1805110error.txt");
	asmOut.open("code.asm");
	check.open("check.txt");
	
   string s="";
   s+="anika ";
	yyin=fp;
	
	yyparse();

	table->printAllScopeTable(logout);
	

	logout<<"Total lines: "<<line_count<<endl;
	logout<<"Total errors: "<<errorCount<<endl;


	
	return 0;
}

