%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

typedef struct variabel{
	char n[10];
	float value;
}variabel;

variabel var[100];
static int count=0;

// float symbols[52];
float symbolVal(char symbol[10]);
void updateSymbolVal(char symbol[10], float val);
void newVar(char symbol[10],float value);
int notval(int a);
int orval(int a,int b);
int andval(int a , int b);
%}

%union {float num; char id[10];}         /* Yacc definitions */
%start line
%token print
%token exit_command
%token comment
%token aa
%token oo
%token <num> number
%token <id> identifier
%type <num> line exp term exptwo expthree brac
%type <id> assignment

%%

/* descriptions of expected inputs     corresponding actions (in C) */

line    : assignment ';'		{;}
		| exit_command ';'		{exit(EXIT_SUCCESS);}
		| print exp ';'			{printf("Printing %.2f\n", $2);}
		| line assignment ';'	{;}
		| line print exp ';'	{printf("Printing %.2f\n", $3);}
		| line exit_command ';'	{exit(EXIT_SUCCESS);}
		| comment				{;}
		| line comment			{;}
        ;

assignment : identifier '=' exp  { updateSymbolVal($1,$3); }
		   ;



exp 	: exp '+' exptwo        {$$ = $1 + $3;}
       	| exp '-' exptwo        {$$ = $1 - $3;}
		| exp aa exptwo			{$$ = andval($1,$3);}
		| exp oo exptwo			{$$ = orval($1,$3);}
		| '!' exptwo			{$$ = notval($2);}
		| exptwo				{$$ = $1;}
		;

exptwo	: exptwo '*' expthree   {$$ = $1 * $3;}
		| expthree				{$$ = $1;}
		;

expthree : expthree '/' brac	{$$ = $1 / $3;}
		 | brac					{$$ = $1;}
		 ;

brac	 : '(' exp ')'			{$$ = $2;}
		 | term					{$$ = $1;}
		 ;



term   	: number                {$$ = $1;}
		| identifier			{$$ = symbolVal($1);} 
        ;





%%                     /* C code */


// + and - are left associative

// exp    	: term                  {$$ = $1;}
//        	| exp '+' term          {$$ = $1 + $3;}
//        	| exp '-' term          {$$ = $1 - $3;}
// 		| '!' term				{$$ = notval($2);}
// 		| exp aa term			{$$ = andval($1,$3);}
// 		| exp oo term			{$$ = orval($1,$3);}
//        	;







int computeSymbolIndex(char token[10])
{

	int i=0;
	int index=-1;

	for(i =0;i<100;i++){
		if(strcmp(token,var[i].n)==0){
			index=i;
			break;
		}
	}
	printf("computeSYmbolIndex ,token ,index = %s %d \n",token,index);
	return index;

} 

// creates a new variabel 
void newVar(char symbol[10],float value){
	
	count++;
	int i=0;
	for(i =0;i<10;i++){
		var[count].n[i]=symbol[i];
	}
	// strcpy(var[count].n,symbol);
	var[count].value =value;
	printf("newVar  symbol= %s , index = %d \n",symbol,count);

}


/* returns the value of a given symbol */
float symbolVal(char symbol[10])
{
	int bucket = computeSymbolIndex(symbol);
	return var[bucket].value;
}

/* updates the value of a given symbol */
void updateSymbolVal(char symbol[10], float val)
{
	int bucket = computeSymbolIndex(symbol);
	if(bucket ==-1){
		//the variable does not exists so create new one
		newVar(symbol,val);
	}else{
		var[bucket].value = val;
	}
}

int notval(int a){
	if(a>0){
		return 0;
	}else{
		return 1;
	}
}

int andval(int a , int b){
	if(a>0 && b>0){
		return 1;
	}else{
		return 0;
	}
}

int orval(int a , int b){
	if(a==0 && b==0){
		return 0;
	}else{
		return 1;
	}
}



int main (void) {
	/* init symbol table */
	int i;
	for(i=0; i<100; i++) {
		var[i].value = 0;
		int k=0;
		for (int k=0;k<10;k++){
			var[i].n[k]='\0';
		}
	}

	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 

