%{
#include <math.h>
#include "y.tab.h"
void yyerror (char *s);
int yylex();

%}
%%
[0-9]+|[0-9]*\.[0-9]+                   {yylval.num = atof(yytext); return number;}
"print"				                    {return print;}
"exit"				                    {return exit_command;}
[a-zA-Z]			                    {yylval.id = yytext[0]; return identifier;}

[ \t\n]                                 ;
[-+=;]           	                    {return yytext[0];}          
.                                       {ECHO; yyerror ("unexpected character");}
[/][/][a-zA-Z0-9!@#$%^&*() \t\n]*[\n]   {return comment;}
                                                     

%%
int yywrap (void) {return 1;}

