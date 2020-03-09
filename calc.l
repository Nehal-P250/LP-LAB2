%{
#include <math.h>
#include <string.h>
#include "y.tab.h"

int assign(char *s);
void yyerror (char *s);
int yylex();

%}
%%
[0-9]+|[0-9]*\.[0-9]+                   {yylval.num = atof(yytext); return number;}
"print"				                    {return print;}
"exit"				                    {return exit_command;}
"ee"                                    {return eqeq;}
"lte"                                   {return lesste;}
"gte"                                   {return grette;}
"lt"                                    {return lesst;}
"gt"                                    {return grett;}
[a-zA-Z]+[0-9]*			                {strcpy(yylval.id,yytext); return identifier;}
[ \t\n]                                 ;
[-+=;!()*/]           	                {return yytext[0];}          
[/][/][a-zA-Z0-9!@#$%^&*() \t\n]*[\n]   {return comment;}
[&&]                                    {return aa;}  
[||]                                    {return oo;}    
.                                       {ECHO; yyerror ("unexpected character");}                                              

%%


// [==]                                    {return eqeq;}
// [<=]                                    {return lesste;}
// [>=]                                    {return grette;}
// [<]                                     {return lesst;}
// [>]                                     {return grette;}



int yywrap (void) {return 1;}
int assign(char *s){
    if(strlen(s)>9){
        ECHO ; yyerror("improper variable name");
    }else{
        int i=0;
        for(i=0;i<strlen(s);i++){
            yylval.id[i]=s[i];
        }
    }
    return identifier;
}

