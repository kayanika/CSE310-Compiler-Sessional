
#include "1805110.h"


class hp{
     string varType;
    
     vector<symbolInfo*> symbols;

     public:
     hp(){
       
     }
     int size(){
         return symbols.size();
     }
     void setVarType(string str){
         varType=str;
     }
    string getVarType(){
         return varType;
     }
     symbolInfo* at(int i){
         return symbols.at(i);
     }
     void push(symbolInfo* symbol){
         symbols.push_back(symbol);
     }
     void push(hp* symbol){
         symbols.push_back(symbol->at(0));
     }
};