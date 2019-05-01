%{
#include <stdio.h>
#include <stdlib.h>
#include "http_parser.tab.h"								
#include "__http.h"

extern int yyerror(yyscan_t yyscanner, const char *s);

int yywrap(yyscan_t yyscanner) 
{
  return 1;
}

%}

%option reentrant
%option bison-bridge
%option debug
%option warn
%option header-file="parser/http_parser.yy.h"
%option outfile="parser/http_parser.yy.c"

/*%x STRING*/

/*SPACE       [ \t\r\n]*/
DIGIT       [0-9]
INTEGER     -?(0|[1-9]{DIGIT}*)
NUMBER      {INTEGER}\.{DIGIT}+
ALPHA       [a-zA-Z]
HEX         [0-9a-fA-F]
CRLF        [\r\n]
SPACE       [ ]
PROTOCOL    (HTTP)\/{DIGIT}\.{DIGIT} 
METHOD      (OPTIONS|GET|HEAD|POST|PUT|DELETE|TRACE|CONNECT)
%%

<INITIAL>{ALPHA}({SPACE}{ALPHA})* {
  printf("Reason Phrase is %s\n", yytext);
		return REASON_PHRASE;
}

<INITIAL>{METHOD} {
		printf("Matched with METHOD (%s) length %zu\n", yytext, yyleng);
		yylval->str = (unsigned char *)yytext;
  return HTTP_METHOD;
}

<INITIAL>{SPACE}* {
  printf("matched with WS\n");
		return SPACE;
}

<INITIAL>"*" {
  printf("Got the star\n");
  return('*');		
}

<INITIAL>"/" {
  printf("Got the / (%s)\n", yytext);
  return('/');		
}

<INITIAL>{PROTOCOL} {
  printf("Got the Method %s\n", yytext);
		yylval->str = (unsigned char *)yytext;
		return HTTP_VERSION;
}


<INITIAL>{DIGIT}{3} {
  printf("Status Code is %d\n", atoi(yytext));
		return STATUS_CODE;
}

<INITIAL>{CRLF} {
		printf("Matched with CRLF \n");						
  /*! End of line */
  return CRLF;								
}

<INITIAL>{CRLF}$ {
		printf("Matched with CRLF \n");						
  /*! End of line */
  return CRLF;								
}

<INITIAL>. {
	printf("Got the string %s\n", yytext);							
	yyerror(yyscanner, "\n(Naushad)Syntax Error!!");
}

<INITIAL><<EOF>> {
  printf("Parsed successfully\n");
		yyterminate();
}

%%
