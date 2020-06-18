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
float modval(float a , float b);
int lt(int a , int b);
int gt(int a , int b);
int et(int a , int b);
int gte(int a , int b);
int lte(int a , int b);

%}

%union {float num; char id[10];}         /* Yacc definitions */
%start line
%token print
%token exit_command
%token comment
%token mif
%token melse
%token mwhile
%token <num> number
%token <id> identifier
%type <num> line exp term exptwo expthree brac 
%type <id> assignment

%%

/* descriptions of expected inputs     corresponding actions (in C) */

line    : assignment ';'				{;}
		| exit_command ';'				{if(eval) exit(EXIT_SUCCESS);}
		| print exp ';'					{if(eval) printf("Printing %.2f\n", $2);}
		| line assignment ';'			{;}
		| line print exp ';'			{if(eval) printf("Printing %.2f\n", $3);}
		| line exit_command ';'			{if(eval) exit(EXIT_SUCCESS);}
		| comment						{;}
		| line comment					{;}
		| mif line '}'					{eval=1;}
		| melse line '}'  				{eval=1;}
		| line mif line '}'				{eval=1;}
		| line melse line '}'  			{eval=1;}
        ;

assignment : identifier '=' exp  {if(eval) updateSymbolVal($1,$3); }
		   | identifier '+''=' exp  {updateSymbolVal($1,symbolVal($1) + $4); }
		   | identifier '-''=' exp  {updateSymbolVal($1,symbolVal($1) - $4); }
		   | identifier '/''=' exp  {updateSymbolVal($1,symbolVal($1) / $4); }
		   | identifier '*''=' exp  {updateSymbolVal($1,symbolVal($1) * $4); }
		
		  ;

condition    	:
				| term '<' term        	{$$ = lt($1,$3);}     
       			| term '>' term        	{$$ = gt($1,$3);}     
				| term '<' '=' term		{$$ = lte($1,$3);}     
				| term '>' '=' term		{$$ = gte($1,$3);}      
				| term '=' '=' term		{$$ = et($1,$3);}
        		;





exp 	: exp '+' exptwo        	{$$ = $1 + $3;}
       	| exp '-' exptwo        	{$$ = $1 - $3;}
		| exp '%' exptwo        	{$$ = modval($1,$3);}   
		| exp '&' '&' exptwo		{$$ = andval($1,$3);}
		| exp '|' '|' exptwo		{$$ = orval($1,$3);}
		| exp '<' exptwo        	{$$ = lt($1,$3);}     
       	| exp '>' exptwo        	{$$ = gt($1,$3);}     
		| exp '<' '=' exptwo		{$$ = lte($1,$3);}     
		| exp '>' '=' exptwo		{$$ = gte($1,$3);}      
		| exp '=' '=' exptwo		{$$ = et($1,$3);}  	
		| '!' exptwo				{$$ = notval($2);}
		| exptwo					{$$ = $1;}
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



term   	: number		           {$$ = $1;}
		| identifier				{$$ = symbolVal($1);} 
        ;






%%                    
#include<ctype.h>




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
	return index;

} 

// creates a new variabel 
void newVar(char symbol[10],float value){
	
	count++;
	strcpy(var[count].n,symbol);
	var[count].value =value;

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





char st[100][10];

//top pointer for the expresion stack
int top=0;
// t will be for generating temprory variable that will be "t"+string(t);
int t=0;
push()
{
	strcpy(st_exp[++top],yytext);
}
codegen()
{
	strcpy(temp,"t");
	strcat(temp,i_);
	printf("%s = %s %s %s\n",temp,st_exp[top-2],st_exp[top-1],st_exp[top]);
	top-=2;
	strcpy(st_exp[top],temp);
	i_[0]++;
}
codegen_umin()
{
	strcpy(temp,"t");
	strcat(temp,i_);
	printf("%s = -%s\n",temp,st_exp[top]);
	top--;
	strcpy(st_exp[top],temp);
	i_[0]++;
}
codegen_assign()
{
	printf("%s = %s\n",st_exp[top-2],st_exp[top]);
	top-=2;
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








