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

// if one of the block in the if {} else 
// or if { } else if(){ } ..gets evaluated sucessufully then the 
// rest should not get evaluated . if_done = 1 means that one of the 
// above if or else if statement is evaluated and hence we should not 
// evaluate current block; 
//finally on end if else blocks if_done  will be reset to 0
int if_done = 0;

// if 1 then we can evaluate eles we can't
int eval =1;



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
%token mendif
%token melseif
%token increment
%token decrement
%token aa
%token oo
%token lesst
%token grett
%token lesste
%token grette
%token eqeq
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
		| ifgrammar line '}'			{eval=1;}
		| elsegrammar line '}'  		{eval=1;}
		| mendif ';'					{if_done=0;}
		| line ifgrammar line '}'		{eval=1;}
		| line elsegrammar line '}'  	{eval=1;}
		| line mendif ';'				{if_done=0;}
		| elseifgrammar line '}'		{eval=1;}
		| line elseifgrammar line '}'	{eval=1;}
        ;

assignment : identifier '=' exp  {if(eval) updateSymbolVal($1,$3); }
		   | identifier '+''=' exp  {if(eval) updateSymbolVal($1,symbolVal($1) + $4); }
		   | identifier '-''=' exp  {if(eval) updateSymbolVal($1,symbolVal($1) - $4); }
		   | identifier '/''=' exp  {if(eval) updateSymbolVal($1,symbolVal($1) / $4); }
		   | identifier '*''=' exp  {if(eval) updateSymbolVal($1,symbolVal($1) * $4); }
		
		  ;



ifgrammar	: mif exp '{'  	{ 	
								if($2){
									if_done=1;
									eval =1;
								}else{
									eval=0;
									if_done=0;
								}
								
							}

			;
			

elsegrammar	: melse '{'  	{ 	
									if(if_done==0){
										eval=1;
									}else{
										eval=0;
									}
								
								}
			;
			

elseifgrammar	: melseif exp '{'  	{ 
											
										if(if_done==0){
											if($2){
												if_done=1;
												eval=1;
											}else{
												eval=1;
											}
										}else{
											eval=0;
										}
								
									}
			;
			









exp 	: exp '+' exptwo        	{ if(eval) $$ = $1 + $3;}
       	| exp '-' exptwo        	{ if(eval) $$ = $1 - $3;}
		| exp '%' exptwo        	{ if(eval) $$ = modval($1,$3);}   
		| exp aa exptwo				{ if(eval) $$ = andval($1,$3);}
		| exp oo exptwo				{ if(eval) $$ = orval($1,$3);}
		| exp lesst exptwo        	{ if(eval) $$ = lt($1,$3);}     
       	| exp grett exptwo        	{ if(eval) $$ = gt($1,$3);}     
		| exp lesste exptwo			{ if(eval) $$ = lte($1,$3);}     
		| exp grette exptwo			{ if(eval) $$ = gte($1,$3);}      
		| exp eqeq exptwo			{ if(eval) $$ = et($1,$3);}  	
		| '!' exptwo				{ if(eval) $$ = notval($2);}
		| exptwo					{ if(eval) $$ = $1;}
		;

exptwo	: exptwo '*' expthree   { if(eval) $$ = $1 * $3;}
		| expthree				{ if(eval) $$ = $1;}
		;

expthree : expthree '/' brac	{ if(eval) $$ = $1 / $3;}
		 | brac					{ if(eval) $$ = $1;}
		 ;

brac	 : '(' exp ')'			{ if(eval) $$ = $2;}
		 | term					{ if(eval) $$ = $1;}
		 ;



term   	: number                { if(eval) $$ = $1;}
		| identifier			{ if(eval) $$ = symbolVal($1);} 
		| identifier increment		{if(eval==1){$$ = symbolVal($1); updateSymbolVal($1,symbolVal($1)+1);}}
		| identifier decrement		{if(eval==1){$$ = symbolVal($1); updateSymbolVal($1,symbolVal($1)-1);}}
		| increment identifier 		{if(eval==1){updateSymbolVal($2,symbolVal($2)+1); $$ = symbolVal($2);}}
		| decrement identifier 		{if(eval==1){updateSymbolVal($2,symbolVal($2)-1); $$ = symbolVal($2);}}
        ;
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



// relexp 	: relexp '<' exp        	{$$ = lt($1,$3);}     
//        	| relexp '>' exp        	{$$ = gt($1,$3);}     
// 		| relexp lesste exp			{$$ = et($1,$3);}     
// 		| relexp grette exp			{$$ = gte($1,$3);}      
// 		| relexp eqeq exp			{$$ = lte($1,$3);}      
// 		| exp						{$$ = $1;}	
// 		;








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


int lt(int a , int b){
	if(a < b){
		return 1;
	}else{
		return 0;
	}
}

int gt(int a , int b){
	if(a > b){
		return 1;
	}else{
		return 0;
	}
}

int et(int a , int b){
	if(a == b){
		return 1;
	}else{
		return 0;
	}
}

int lte(int a , int b){
	if(a <= b){
		return 1;
	}else{
		return 0;
	}
}

int gte(int a , int b){
	if(a >= b){
		return 1;
	}else{
		return 0;
	}
}


float modval(float a , float b){
	
	float ans;
	if(b>0){
		ans = a - (b*((int)(a/b)));
		return ans;
	}else{
		printf("Divide BY Zero \n");
	}
	return -1;

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

