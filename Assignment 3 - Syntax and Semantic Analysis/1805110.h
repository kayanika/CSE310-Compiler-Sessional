#include <iostream>
#include <cstring>
#include<fstream>
#include <bits/stdc++.h>

using namespace std;

class symbolInfo
{
private:
    string name;
    string type;
    symbolInfo* nextSymbolInfo;
    string variableType;
    vector<pair<string,string>> parameters;
    string returnType;
    string typeSpecifier;

    bool alreadyDefined;

public:
    symbolInfo* getNextSymbolInfo(){
    return nextSymbolInfo;
    }
    void setNextSymbolInfo(symbolInfo* symbol){
    nextSymbolInfo=symbol;
    }
    symbolInfo(string Name,string Type )
    {

        name=Name;
        type=Type;
        alreadyDefined=false;
        nextSymbolInfo=nullptr;
        typeSpecifier="";
        returnType="";
        variableType="";
        
    }
    void setTypeSpecifier(string temp){
                typeSpecifier=temp;
    }
    string getTypeSpecifier(){
             return typeSpecifier;
    }
    void setReturnType(string temp){
             returnType=temp;
    }
    string getReturnType(){
        return returnType;
    }
    void setVariableType(string temp){
        variableType=temp;
    }
    string getVariableType(){
        return variableType;
    }
    void clearFuncParameters(){
        parameters.clear();
    }
    void addParameter(string temp1,string temp2){
         parameters.push_back(make_pair(temp1,temp2));
    }
    vector<pair<string,string>> getParameters(){
        return parameters;
    }
    void setAlreadyDefined(){
        alreadyDefined=true;
    }
    bool getAlreadyDefined(){
        return alreadyDefined;
    }

    string getName()
    {
        return name;
    }
    string getType()
    {
        return type;
    }
    void setName(string Name)
    {
        name=Name;
    }
    void setType(string Type)
    {
        type=Type;
    }

    ~symbolInfo()
    {

    }
};

class scopeTable
{
private:
    int tableSize;
    symbolInfo** buckets;
    scopeTable* parentScope;
    int childScopeAttempt;
    string uniqueId;

public:
    int getChildScopeAttempt(){
    return childScopeAttempt;
    }
    void setChildScopeAttempt(int attempt){
        childScopeAttempt=attempt;
    }
    string getUniqueId(){
    return uniqueId;
    }
    void setParentScope(scopeTable* scope){
        parentScope=scope;
    }
    scopeTable* getParentScope(){
    return parentScope;}
   void setUniqueId(string id){
    uniqueId=id;
    }

    scopeTable(int tablesize,string parentId,int currentScopeAttemptNo)
    {
        tableSize=tablesize;
        childScopeAttempt=0;
         cout<<"CONSTRUCTOR CALLED"<<endl;
        buckets=new symbolInfo*[tablesize];
        for(int i=0; i<tablesize; i++)
        {
            buckets[i]=nullptr;
        }
        parentScope=nullptr;
        if(parentId==""){
        uniqueId=parentId+to_string(currentScopeAttemptNo);}
        else
            uniqueId=parentId+"."+to_string(currentScopeAttemptNo);

           // cout<<"Creating new scope ,the parent id :"<<parentId<< " the uique id :"<<uniqueId<<endl;

    }
    bool alreadyExist(string item){
         int i=(sdbmhash(item))%tableSize;
       
         symbolInfo* temp= buckets[i];
         cout<<"2"<<endl;
            while(temp!=nullptr)

            {     
                cout<<temp->getName()<<"   "<<temp->getType()<<endl;
                 cout<<"3"<<endl;
                if(temp->getName()==item)
                {

                    return true;
                }
                temp=temp->getNextSymbolInfo();



            }
            return false;

    }

    bool insertSymbol(string name,string type,ofstream &fout)
    {    int chainPosition=0;
       

        if(!alreadyExist(name)){
            cout<<"doesnn't exist"<<endl;        int i=(sdbmhash(name))%tableSize;

     if(buckets[i]==nullptr)
        {  
            buckets[i]=new symbolInfo(name, type);

        }
        else
        {
            symbolInfo* temp= buckets[i];
           
            while(temp->getNextSymbolInfo()!=nullptr)
            {   chainPosition++;
                temp=temp->getNextSymbolInfo();

            }
            chainPosition++;
          

            temp->setNextSymbolInfo(new symbolInfo(name, type));

        }
        cout<<"inserted name : "<<name<<"       type "<<type<<endl;
         
        
        cout<<"Inserted in ScopeTable # "<<uniqueId<<" at position "<<i<<","<< chainPosition<<endl;
       // fout<<"Inserted in ScopeTable # "<<uniqueId<<" at position "<<i<<","<< chainPosition<<endl;
       

        return true;
        }
        else{
            cout<<"<"<<name<<","<<type<<"> already exists in current ScopeTable"<<endl;
            // fout<<name<<" already exists in current ScopeTable"<<endl;
           
        }


        return false;
    }

    symbolInfo* lookUp(string item)
    {
        int i=(sdbmhash(item))%tableSize;
        int chainPosition=0;
            symbolInfo* temp= buckets[i];
            while(temp!=nullptr)

            {
                if(temp->getName()==item)
                {
                    cout<<"Found in ScopeTable# "<<uniqueId<<" at position "<<i<<", "<<chainPosition<<endl;
                    return temp;
                }
                temp=temp->getNextSymbolInfo();
                chainPosition++;


            }


        return nullptr;
    }

    bool deleteSymbol(string item)
    {
       int i=(sdbmhash(item))%tableSize;
        symbolInfo* temp1;
        int chainPosition=0;
        symbolInfo* tempNext=nullptr;
            temp1=buckets[i];
            if(temp1!=nullptr)
            {
                if(buckets[i]->getName()==item)
                {
                          buckets[i]=temp1->getNextSymbolInfo();
                          cout<<"Found in ScopeTable# "<<uniqueId<<" at position "<<i<<", "<<chainPosition<<endl;
                          cout<<"Deleted Entry "<<i<<", "<<chainPosition<<" from current ScopeTable"<<endl;
                          delete temp1;
                          return true;
                }
                else
                {   cout<<"now checking bucket no "<<i<<" middle elements"<<endl;
                    while(temp1->getNextSymbolInfo()!=nullptr)
                    {   chainPosition++;
                        if(temp1->getNextSymbolInfo()->getName()==item){
                            tempNext=temp1->getNextSymbolInfo();
                            temp1->setNextSymbolInfo(tempNext->getNextSymbolInfo());
                             cout<<"Found in ScopeTable# "<<uniqueId<<" at position "<<i<<", "<<chainPosition<<endl;
                             cout<<"Deleted Entry "<<i<<", "<<chainPosition<<" from current ScopeTable"<<endl;
                            delete tempNext;

                         return true;

                        }
                            temp1=temp1->getNextSymbolInfo();
                    }
                }
            }


              cout<<item<<" not found"<<endl;
         return false;




    }

    unsigned int sdbmhash( string str)

    {

       unsigned  int hash2 = 0;
        int c;

        for (int i=0;i<str.size(); i++ )
        {
            hash2 = str[i] + (hash2 << 6) + (hash2 << 16) - hash2;

        }

        return hash2;
    }


    void add(string name,string type)
    {

    }
    void print(ofstream &fout)
    {
        // cout<<"table size "<<tableSize<<endl;
        for (int i=0; i<tableSize; i++)
        {

            
            symbolInfo* temp= buckets[i];
            if(temp!=nullptr){
                
                         cout<<i<<"---> ";
                          fout<<i<<"---> ";
            
            while(temp!=nullptr)

            {
                cout<<"<"<<temp->getName()<<" : "<<temp->getType()<<">  ";
                 fout<<"<"<<temp->getName()<<" : "<<temp->getType()<<">  ";
                temp=temp->getNextSymbolInfo();


            } cout<<endl;
               fout<<endl;
            }

        }
        cout<<endl;
        fout<<endl;
    }
    ~scopeTable()
    {

        for (int i = 0; i <tableSize ; ++i)
        {
            symbolInfo* temp=buckets[i];
            symbolInfo* temp2;
            while(temp!=nullptr){
                  temp2=temp;
                 temp=temp->getNextSymbolInfo();
                 delete temp2;
            }
        }

        delete[] buckets;
    }

};

class symbolTable{
    scopeTable* currentScopeTable;
   
   
    int tablesize;
    public:


    symbolTable(int sz){

        tablesize=sz;
        currentScopeTable=new scopeTable(tablesize,"",1);
      
       




    }

    void enterScope(){
        if(currentScopeTable!=nullptr){
                int attempt=currentScopeTable->getChildScopeAttempt();attempt++;
        currentScopeTable->setChildScopeAttempt(attempt);
    scopeTable* newScopeTable=new scopeTable(tablesize,currentScopeTable->getUniqueId(),currentScopeTable->getChildScopeAttempt());

    newScopeTable->setParentScope(currentScopeTable);
    currentScopeTable=newScopeTable;
    cout<<"New ScopeTable with id "<<currentScopeTable->getUniqueId()<<" created"<<endl;
    }
    else
        currentScopeTable=new scopeTable(tablesize,"",1);

    }

    void exitScope(){
        if(currentScopeTable!=nullptr){

    scopeTable* current=currentScopeTable;
    currentScopeTable=currentScopeTable->getParentScope();
   cout<<"ScopeTable with id "<<current->getUniqueId()<<" removed"<<endl;
   if(current->getUniqueId()=="1")cout<<"Destroying the first scope"<<endl;
    delete current;

    }
   else
    cout<<"NO COURRENT SCOPE";

    }
    bool insertNewSymbol(string name, string type,ofstream &f){
     
        
          cout<<"inside symbol table insert"<<endl;
   
        if(currentScopeTable!=nullptr){
      if(  currentScopeTable->insertSymbol(name,type,f)){
           
         // f<<"finsihed symbol table insert, ID :"<< name <<endl;
          cout<<"finsihed symbol table insert, ID :"<< name <<endl;
        return true;
      }

      return false;
      }
      cout<<"CURRENTLY NO SCOPE EXITS. PLEASE ENTER A SCOPE FIRST.";

      return false;
    }

    bool removeSymbol(string item){
       if(currentScopeTable!=nullptr){
        if(currentScopeTable->deleteSymbol(item))
            return true;
        return false;}
        cout<<"CURRENTLY NO SCOPE EXITS. PLEASE ENTER A SCOPE FIRST.";return false;

    }
    symbolInfo* lookUpSymbol(string item)
    {
        if(currentScopeTable!=nullptr)
        {
            scopeTable* currentScope=currentScopeTable;
            while(currentScope!=nullptr)
            {
                symbolInfo* symbol=currentScope->lookUp(item);
                if(symbol==nullptr)
                {
                    currentScope=currentScope->getParentScope();
                }
                else
                {
                    return symbol;
                }
            } cout<<item<<" not found"<<endl;
            return nullptr;

        }
      cout<<"CURRENTLY NO SCOPE EXITS. PLEASE ENTER A SCOPE FIRST.";
      return nullptr;
    }
    void printCurrentScopeTable(ofstream &f){
        if(currentScopeTable!=nullptr){
        cout<<"ScopeTable # "<<currentScopeTable->getUniqueId()<<endl;
        currentScopeTable->print(f);
        return ;}
        cout<<"CURRENTLY NO SCOPE EXITS. PLEASE ENTER A SCOPE FIRST.";

    }
    void printAllScopeTable(ofstream &f){
    


    scopeTable* currentScope=currentScopeTable;
      while(currentScope!=nullptr){

            f<<"ScopeTable # "<<currentScope->getUniqueId()<<endl;
            currentScope->print(f);
         currentScope=currentScope->getParentScope();

    }
    }
    ~symbolTable(){
       while(currentScopeTable!=nullptr)
        exitScope();

    }

};

/*int main()
{
   int tablesize;

    ifstream myfile;
myfile.open("input.txt");

if ( myfile.is_open() ) {
int sz; char ch1,ch2; string string1,string2; myfile>>sz;   symbolTable s1(sz);

while(!myfile.eof()){


    myfile>>ch1;
    if(myfile.eof())break;

    if(ch1=='I'){
        myfile>>string1>>string2;
        s1.insertNewSymbol(string1,string2);
        cout<<endl;
    }
    else if(ch1=='S'){
             s1.enterScope();
             cout<<endl;
    }else if(ch1=='L'){
            myfile>>string1;
            s1.lookUpSymbol(string1);
            cout<<endl;

    }else if(ch1=='P'){
        myfile>>ch2;
        if(ch2=='A'){

           s1.printAllScopeTable();
           cout<<endl;
        }else{ s1.printCurrentScopeTable();
        cout<<endl;
        }
    }
    else if(ch1=='D'){
            myfile>>string1;
            s1.removeSymbol(string1);cout<<endl;
    }
    else if(ch1=='E'){
        s1.exitScope();cout<<endl;
    }

}


  }



else {
std::cout << "Couldn't open file\n";
}

    return 0;
}*/

