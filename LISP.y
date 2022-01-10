%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
%}
%code requires{
	#define variable_maxname 20
	void yyerror(const char *message);
	
	typedef struct variable* variable_pointer;
	typedef struct node* node_pointer;

	typedef struct variable{ //store variable
		char name[variable_maxname];
		node_pointer val;
		variable_pointer next;
	}variable;
	
	typedef struct node{
		char type;	//'o':operation, 'n':number, 'i':id, 'f':if, 'u':fun
		node_pointer left, right, nodep;
		int value_num;	//number
		variable_pointer var;	//id
		char operation;	//operation
	} node;

	node_pointer createnewnode(char type, int number, variable_pointer var, char operation, node_pointer nodep);
	int getresult(node_pointer root);
	variable_pointer storevariable(variable_pointer head, variable_pointer new);
	variable_pointer createvariable(char name[variable_maxname]);
	variable_pointer findvariable(variable_pointer head, variable_pointer target);

	variable_pointer variablehead; //defined variable
	variable_pointer functionhead; //defined function
	variable_pointer tmpfunhead;
	int isfun;
	int i;
}
%union{
	int num;
	node_pointer nodearray;
	char id[variable_maxname];
	node_pointer nodepointer;
	variable_pointer variablepointer;
}
%token <num> NUMBER BOOLVAL
%token <id> ID
%token '+' '-' '*' '/' '%' '<' '>' '=' '(' ')'
%token PRINTNUM PRINTBOOL AND OR NOT IF DEFINE FUN
%type <nodepointer> exp plus minus multiply divide modulus greater smaller equal andop notop orop numop logicalop expplus expmul ifexp testexp thenexp elseexp expand expor
%type <nodepointer> funexp funbody funcall
%type <nodearray> params
%type <variablepointer> funids funid variable
%left '+' '-'
%left '/' '*'

%%
program		: stmt program
			| stmt
			;
stmt		: exp
			| printstmt
			| defstmt
			;
printstmt	: '('PRINTNUM exp')'	{printf("%d\n", getresult($3));}
			| '('PRINTBOOL exp')'	{ 
										if(getresult($3)){
                                            printf("#t\n");
                                        }else{
                                            printf("#f\n");
                                        }
									}
exp			: BOOLVAL				{$$ = createnewnode('b', $1, NULL, '\0', NULL);}
			| NUMBER				{$$ = createnewnode('n', $1, NULL, '\0', NULL);}
			| numop					
			| logicalop
			| ifexp
			| variable				{$$ = createnewnode('i', 0, $1, '\0', NULL);}		
			| funexp
			| funcall				
			;	
numop		: plus					
			| minus					
			| multiply				
			| divide				
			| modulus				
			| greater				
			| smaller				
			| equal
			;
plus		: '(' '+' exp expplus ')'	{$$ = createnewnode('o', 0, NULL, '+', NULL); $$->left = $3; $$->right = $4;}
			;
expplus		: exp expplus				{$$ = createnewnode('o', 0, NULL, '+', NULL); $$->left = $1; $$->right = $2;}
			| exp						
			;
minus		: '(' '-' exp exp ')'       {$$ = createnewnode('o', 0, NULL, '-', NULL); $$->left = $3; $$->right = $4;}
			;
multiply	: '(' '*' exp expmul ')'	{$$ = createnewnode('o', 0, NULL, '*', NULL); $$->left = $3; $$->right = $4;}
			;
expmul		: exp expmul		        {$$ = createnewnode('o', 0, NULL, '*', NULL); $$->left = $1; $$->right = $2;}
			| exp					
			;
divide		: '(' '/' exp exp ')'	    {$$ = createnewnode('o', 0, NULL, '/', NULL); $$->left = $3; $$->right = $4;}
			;
modulus		: '(' '%' exp exp ')'	    {$$ = createnewnode('o', 0, NULL, '%', NULL); $$->left = $3; $$->right = $4;}
			;
greater		: '(' '>' exp exp ')'	    {$$ = createnewnode('o', 0, NULL, '>', NULL); $$->left = $3; $$->right = $4;}
			;
smaller		: '(' '<' exp exp ')'	    {$$ = createnewnode('o', 0, NULL, '<', NULL); $$->left = $3; $$->right = $4;}
			;
equal		: '(' '=' exp exp ')'	    {$$ = createnewnode('o', 0, NULL, '=', NULL); $$->left = $3; $$->right = $4;}
			;
logicalop	: andop					
			| orop					
			| notop					
			;
andop		: '(' AND exp expand ')'	{$$ = createnewnode('o', 0, NULL, '&', NULL); $$->left = $3; $$->right = $4;}
			;
expand		: exp expand				{$$ = createnewnode('o', 0, NULL, '&', NULL); $$->left = $1; $$->right = $2;}
			| exp						
			;
orop		: '(' OR exp expor ')'	    {$$ = createnewnode('o', 0, NULL, '|', NULL); $$->left = $3; $$->right = $4;}
			;
expor		: exp expor				    {$$ = createnewnode('o', 0, NULL, '|', NULL); $$->left = $1; $$->right = $2;}
			| exp
			;
notop		: '(' NOT exp ')'		    {$$ = createnewnode('o', 0, NULL, '!', NULL); $$->left = $3;}
			;
defstmt		: '(' DEFINE variable exp ')'   { 
												if($4->type == 'u'){
													variable_pointer current = findvariable(functionhead, $3);
													if(!current){ //no defined
														functionhead = storevariable(functionhead, $3);
														current = $3;
													}
													current->val = $4;
												}else{
													variable_pointer current = findvariable(variablehead, $3);
													if(!current){ //no defined
														variablehead = storevariable(variablehead, $3);
														current = $3;
													}
													current->val = createnewnode('n', getresult($4), NULL, '\0', NULL);
												}
											}
			;
variable	: ID					    {$$ = createvariable($1);}
funexp		: '(' FUN funid funbody ')' {$$ = createnewnode('u', 0, $3, '\0', $4);}
			;
funid		: '(' funids ')'			{$$ = $2;}
			| '(' ')'					{$$ = NULL;}
funids		: funids ID					{$$ = storevariable($1, createvariable($2));}
			| ID						{$$ = createvariable($1);}
			;							
funbody		: exp
			;
funcall		: '(' funexp params ')'		{
											variable_pointer current = $2->var;
											int i = 0;
											while(current){
												current->val = &($3[i]);
												i++;
												current = current->next;
											}
											$$ = $2;
										}
			| '(' funexp ')'			{$$ = $2;}
			| '(' ID params ')'			{
											node_pointer function = findvariable(functionhead, createvariable($2))->val;
											variable_pointer current = function->var;
											int i = 0;
											while(current){
												current->val = &($3[i]);
												i++;
												current = current->next;
											}
											$$ = function;
										}
			| '(' ID ')'				{$$ = findvariable(functionhead, createvariable($2))->val;}
			;
params		: params exp				{ 
											i = i + 1;
											int j = 0;
											for(j = 0; j < i; j++){
                                                $$[j] = $1[j];
                                            }	
											$$[i] = *$2;
										}
			| exp						{
                                            i = 0;
                                            $$[i] = *$1;
                                        }
			;		
ifexp		: '(' IF testexp thenexp elseexp ')'	{$$ = createnewnode('f', 0, NULL, '\0', $3); $$->left = $4; $$->right = $5; }
			;
testexp		: exp
			;
thenexp		: exp
			;
elseexp		: exp
			;
%%

variable_pointer createvariable(char name[variable_maxname]){
	variable_pointer newvariable = (variable_pointer)malloc(sizeof(variable));
	strcpy(newvariable->name, name);
	newvariable->next = NULL;
	newvariable->val = NULL;
	return newvariable;
}

//store variable new to defined variable or function
variable_pointer storevariable(variable_pointer head, variable_pointer new){
	variable_pointer newhead = head;
	if(newhead){
		variable_pointer current = newhead;
		while(current->next){
			current = current->next;
		}
		current->next = new;
	}else{
		newhead = new;
	}
	return newhead;
}

//find the target variable
variable_pointer findvariable(variable_pointer head, variable_pointer target){
	variable_pointer current = head;
	if(!current){
        return NULL;
    }
		
	while((current->next) &&  strcmp(current->name, target->name) != 0){
		current = current->next;
	}
	if(strcmp(current->name, target->name) == 0){
		return current;
	}else{
		return NULL;
	}		
}

node_pointer createnewnode(char type, int number, variable_pointer var, char operation, node_pointer test){
	node_pointer newnode = (node_pointer)malloc(sizeof(node));
	newnode->type = type;
	newnode->left = NULL;
	newnode->right = NULL;
	newnode->nodep = test;
	newnode->operation = operation;
	newnode->value_num = number;
	newnode->var = var;
	return newnode;
}

void yyerror(const char *message){
	printf("syntax error\n");
}

int getresult(node_pointer root){
	node_pointer current = root;
	char t = current->type;
	if(t == 'n' || t == 'b'){   //number
        return current->value_num;
    }else if(t == 'i'){ //id
		if(isfun == 0){
			if(current->var->val){
                return getresult(current->var->val);
            }else{
                return getresult(findvariable(variablehead,  current->var)->val);
            }
		}else{
			variable_pointer tmpvariable = findvariable(tmpfunhead, current->var);
			if(tmpvariable){
				return getresult(tmpvariable->val);
			}else{
                return getresult(findvariable(functionhead, current->var)->val);
            }
		}
	}else if(t == 'f'){ //if
		if(getresult(current->nodep) == 1){
			return getresult(current->left);
        }else{
			return getresult(current->right);
        }
	}else if(t == 'u'){ //fun
		isfun = 1;
		tmpfunhead = current->var;
		int a = getresult(current->nodep);
		isfun = 0;
		return a;
	}else if(t == 'o'){ //operation
		char o = current->operation;
		if(o == '+'){
			return getresult(current->left) + getresult(current->right);
		}else if(o == '-'){
			return getresult(current->left) - getresult(current->right);
		}else if(o == '*'){
			return getresult(current->left) * getresult(current->right);
		}else if(o == '/'){
			return getresult(current->left) / getresult(current->right);
		}else if(o == '%'){
			return getresult(current->left) % getresult(current->right);
		}else if(o == '&'){
			return getresult(current->left) & getresult(current->right);
		}else if(o == '|'){
			return getresult(current->left) | getresult(current->right);
		}else if(o == '!'){
			if(getresult(current->left)){
                return 0;
            }else{
                return 1;
            }
		}else if(o == '>'){
			if(getresult(current->left) > getresult(current->right)){
				return 1;
			}else{
				return 0;
            }
		}else if(o == '<'){
			if(getresult(current->left) < getresult(current->right)){
				return 1;
			}else{
				return 0;
            }
		}else if(o == '='){
			if(getresult(current->left) == getresult(current->right)){
				return 1;
			}else{
				return 0;
            }
		}
	}
	yyerror("type error");
	return 0;
}

int main(int argc, char *argv[]){
    yyparse();
	return 0;
}