%{
#include "y.tab.h"
%}

%%
"#t"					                        {yylval.num = 1; return BOOLVAL;}
"#f"	                                {yylval.num = 0; return BOOLVAL;}
"+"|"-"|"*"|"/"|"<"|">"|"="|"("|")"	  {return yytext[0];}
"print-num"		                        {return PRINTNUM;}
"print-bool"		                      {return PRINTBOOL;}
"mod"						                      {return '%';}
"and"                                 {return AND;}
"or"		                              {return OR;}
"not"		                              {return NOT;}
"define"		                          {return DEFINE;}
"lambda"                              {return FUN;}
"fun"                                 {return FUN;}
"if"			                            {return IF;}
0					                            {yylval.num = atoi(yytext); return NUMBER;}
[1-9][0-9]*	                          {yylval.num = atoi(yytext); return NUMBER;}
-[1-9][0-9]*	                        {yylval.num = atoi(yytext); return NUMBER;}
[a-z]([a-z]|[0-9]|"-")*               {strcpy(yylval.id, yytext); return ID;}		
"\t"|"\r"|" "                         {}
"\n"					                        {}
%%