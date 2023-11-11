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

public:
    symbolInfo* getNextSymbolInfo()
    {
        return nextSymbolInfo;
    }
    void setNextSymbolInfo(symbolInfo* symbol)
    {
        nextSymbolInfo=symbol;
    }
    symbolInfo(string Name, string Type )
    {

        name=Name;
        type=Type;
        nextSymbolInfo=nullptr;
    }

    string getName()
    {
        return name;
    }
    string getType()
    {
        return type;
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
    int getChildScopeAttempt()
    {
        return childScopeAttempt;
    }
    void setChildScopeAttempt(int attempt)
    {
        childScopeAttempt=attempt;
    }
    string getUniqueId()
    {
        return uniqueId;
    }
    void setParentScope(scopeTable* scope)
    {
        parentScope=scope;
    }
    scopeTable* getParentScope()
    {
        return parentScope;
    }
    void setUniqueId(string id)
    {
        uniqueId=id;
    }

    scopeTable(int tablesize,string parentId,int currentScopeAttemptNo)
    {
        tableSize=tablesize;
        childScopeAttempt=0;

        buckets=new symbolInfo*[tablesize];
        for(int i=0; i<tablesize; i++)
        {
            buckets[i]=nullptr;
        }
        parentScope=nullptr;
        if(parentId=="")
        {
            uniqueId=parentId+to_string(currentScopeAttemptNo);
        }
        else
            uniqueId=parentId+"."+to_string(currentScopeAttemptNo);

        // cout<<"Creating new scope ,the parent id :"<<parentId<< " the uique id :"<<uniqueId<<endl;

    }
    bool alreadyExist(string item)
    {
        int i=(sdbmhash(item))%tableSize;
        symbolInfo* temp= buckets[i];
        while(temp!=nullptr)

        {
            // cout<<temp->getName()<<"   "<<temp->getType()<<endl;
            if(temp->getName()==item)
            {

                return true;
            }
            temp=temp->getNextSymbolInfo();



        }
        return false;

    }

    bool insertSymbol(string name,string type)
    {
        int chainPosition=0;

        if(!alreadyExist(name))
        {
            int i=(sdbmhash(name))%tableSize;

            if(buckets[i]==nullptr)
            {
                buckets[i]=new symbolInfo(name, type);

            }
            else
            {
                symbolInfo* temp= buckets[i];
                while(temp->getNextSymbolInfo()!=nullptr)
                {
                    chainPosition++;
                    temp=temp->getNextSymbolInfo();

                }
                chainPosition++;

                temp->setNextSymbolInfo(new symbolInfo(name, type));

            }
            cout<<"Inserted in ScopeTable # "<<uniqueId<<" at position "<<i<<","<< chainPosition<<endl;

            return true;
        }
        else
            cout<<"<"<<name<<","<<type<<"> already exists in current ScopeTable"<<endl;


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
            {
                cout<<"now checking bucket no "<<i<<" middle elements"<<endl;
                while(temp1->getNextSymbolInfo()!=nullptr)
                {
                    chainPosition++;
                    if(temp1->getNextSymbolInfo()->getName()==item)
                    {
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

    unsigned long sdbmhash( string str)

    {

        unsigned long hash2 = 0;
        int c;

        for (int i=0; i<str.size(); i++ )
        {
            hash2 = str[i] + (hash2 << 6) + (hash2 << 16) - hash2;

        }

        return hash2;
    }


    void add(string name,string type)
    {

    }
    void print()
    {
        // cout<<"table size "<<tableSize<<endl;
        for (int i=0; i<tableSize; i++)
        {

            cout<<i<<"---> ";
            symbolInfo* temp= buckets[i];
            while(temp!=nullptr)

            {
                cout<<"<"<<temp->getName()<<" : "<<temp->getType()<<">  ";
                temp=temp->getNextSymbolInfo();


            }
            cout<<endl;

        }
        cout<<endl;
    }
    ~scopeTable()
    {

        for (int i = 0; i <tableSize ; ++i)
        {
            symbolInfo* temp=buckets[i];
            symbolInfo* temp2;
            while(temp!=nullptr)
            {
                temp2=temp;
                temp=temp->getNextSymbolInfo();
                delete temp2;
            }
        }

        delete[] buckets;
    }

};

class symbolTable
{
    scopeTable* currentScopeTable;
    int tablesize;
public:


    symbolTable(int sz)
    {

        tablesize=sz;
        currentScopeTable=new scopeTable(tablesize,"",1);




    }

    void enterScope()
    {
        if(currentScopeTable!=nullptr)
        {
            int attempt=currentScopeTable->getChildScopeAttempt();
            attempt++;
            currentScopeTable->setChildScopeAttempt(attempt);
            scopeTable* newScopeTable=new scopeTable(tablesize,currentScopeTable->getUniqueId(),currentScopeTable->getChildScopeAttempt());

            newScopeTable->setParentScope(currentScopeTable);
            currentScopeTable=newScopeTable;
            cout<<"New ScopeTable with id "<<currentScopeTable->getUniqueId()<<" created"<<endl;
        }
        else
            currentScopeTable=new scopeTable(tablesize,"",1);

    }

    void exitScope()
    {
        if(currentScopeTable!=nullptr)
        {

            scopeTable* current=currentScopeTable;
            currentScopeTable=currentScopeTable->getParentScope();
            cout<<"ScopeTable with id "<<current->getUniqueId()<<" removed"<<endl;
            if(current->getUniqueId()=="1")cout<<"Destroying the first scope"<<endl;
            delete current;

        }
        else
            cout<<"NO COURRENT SCOPE";

    }
    bool insertNewSymbol(string name, string type)
    {
        if(currentScopeTable!=nullptr)
        {
            if(  currentScopeTable->insertSymbol(name,type))
                return true;


            return false;
        }
        cout<<"CURRENTLY NO SCOPE EXITS. PLEASE ENTER A SCOPE FIRST.";
        return false;
    }

    bool removeSymbol(string item)
    {
        if(currentScopeTable!=nullptr)
        {
            if(currentScopeTable->deleteSymbol(item))
                return true;
            return false;
        }
        cout<<"CURRENTLY NO SCOPE EXITS. PLEASE ENTER A SCOPE FIRST.";
        return false;

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
            }
            cout<<item<<" not found"<<endl;
            return nullptr;

        }
        cout<<"CURRENTLY NO SCOPE EXITS. PLEASE ENTER A SCOPE FIRST.";
        return nullptr;
    }
    void printCurrentScopeTable()
    {
        if(currentScopeTable!=nullptr)
        {
            cout<<"ScopeTable # "<<currentScopeTable->getUniqueId()<<endl;
            currentScopeTable->print();
            return ;
        }
        cout<<"CURRENTLY NO SCOPE EXITS. PLEASE ENTER A SCOPE FIRST.";

    }
    void printAllScopeTable()
    {


        scopeTable* currentScope=currentScopeTable;
        while(currentScope!=nullptr)
        {

            cout<<"ScopeTable # "<<currentScope->getUniqueId()<<endl;
            currentScope->print();
            currentScope=currentScope->getParentScope();

        }
    }
    ~symbolTable()
    {
        while(currentScopeTable!=nullptr)
            exitScope();

    }

};

int main()
{


    ifstream myfile;
    myfile.open("input1.txt");

    if ( myfile.is_open() )
    {
        int sz;
        char ch,chh;
        string str1,str2;
        myfile>>sz;
        symbolTable s1(sz);

        while(!myfile.eof() && myfile>>ch)
        {
            switch(ch){
            case 'I' :
            {
                myfile>>str1>>str2;
                s1.insertNewSymbol(str1,str2);
                cout<<endl;
                break;
            }
            case 'S' :
            {
                s1.enterScope();
                cout<<endl;
                 break;
            }
           case 'L' :
            {
                myfile>>str1;
                s1.lookUpSymbol(str1);
                cout<<endl;
                 break;

            }
            case 'P' :
            {
                myfile>>chh;
                if(chh=='A')
                {

                    s1.printAllScopeTable();
                    cout<<endl;
                     break;
                }
                else
                {
                    s1.printCurrentScopeTable();
                    cout<<endl;
                     break;
                }
            }
           case 'D' :
            {
                myfile>>str1;
                s1.removeSymbol(str1);
                cout<<endl;
                 break;
            }
           case 'E' :
            {
                s1.exitScope();
                cout<<endl;
                 break;
            }
            default :{
            cout<<"INVALID INPUT "<<endl;
            }

            }

        }


    }



    else
    {
        cout << "Couldn't open file\n";
    }

    return 0;
}
