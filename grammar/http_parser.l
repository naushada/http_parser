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

/*Exclusive State for String Matching*/
%x STRING MIME_PARAM_SCAN MIME_PARAM_VALUE_SCAN HTTP_BODY_SCAN MESSAGE_BODY_SCAN_START

DIGIT       [0-9]
INTEGER     -?(0|[1-9]{DIGIT}*)
NUMBER      {INTEGER}\.{DIGIT}+
ALPHA       [a-zA-Z]
ALPHANUM    [a-zA-Z0-9]
HEX         [0-9a-fA-F]
CRLF        [\r\n]
SPACE       [ ]
PROTOCOL    (HTTP)\/{DIGIT}\.{DIGIT} 
METHOD      (OPTIONS|GET|HEAD|POST|PUT|DELETE|TRACE|CONNECT)
STR         (\"|\')([ALPHA]([ALPHANUM][\.\/\+\-\%\*])*:?[^\r\n])(\"|\')	
MIME_PARAM_NAME      [ALPHA]([ALPHANUM][\-])*	
BODY_START  {CRLF}{2}


%%


<INITIAL>{METHOD}+ {
  printf("Matched with METHOD (%s) length %zu\n", yytext, yyleng);
  yylval->str = (unsigned char *)yytext;
  return HTTP_METHOD;
}

<INITIAL>{SPACE}+ {
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
  printf("Got the Protocol %s\n", yytext);
  yylval->str = (unsigned char *)yytext;
  return HTTP_VERSION;
}


<INITIAL>{DIGIT}{3} {
  printf("Status Code is %d\n", atoi(yytext));
  return STATUS_CODE;
}

<INITIAL>{CRLF}$ {
  printf("End with CRLF \n");						
  /*! End of line */
  return CRLF;								
}

<INITIAL><<EOF>> {
  printf("Parsed successfully\n");
  return EOF;
}

<INITIAL>{MIME_PARAM_NAME}+ {
  printf("MIME_FIELD is %s\n",yytext);
  BEGIN MIME_PARAM_SCAN;
}

<INITIAL>{ALPHA} {
  printf("\n(Naushad)String is %s\n", yytext);
  yylval->offset = 0;
  //yylval->str[yylval->offset++] = yytext[0];
  printf("Changing the state");
  BEGIN STRING;
}

<MIME_PARAM_SCAN>. {
  if(':' == *yytext)
  {
    BEGIN MIME_PARAM_VALUE_SCAN;
    //yylval->str[yylval->offset] = 0;
    printf("The value is %s\n", yytext);
    return(PARAM);
  }
  //yylval->str[yylval->offset++] = *yytext;
  printf("(Naushad)The value is %s\n", yytext);
}

<MIME_PARAM_VALUE_SCAN>{SPACE}+ {
  printf("MIME VALUE with WS\n");
  return(SPACE);
}


<MIME_PARAM_VALUE_SCAN>. {
  if('\r' == *yytext)
  {
    //BEGIN MIME_PARAM_SCAN;
    //return(VALUE);
  }
  printf("\nMime Valus is %s\n", yytext);
}

<MIME_PARAM_VALUE_SCAN>"\n" {
  BEGIN MIME_PARAM_SCAN;
  return(VALUE);
}

<MIME_PARAM_SCAN>{BODY_START} {
  printf("\nBody Starts\n");
  BEGIN MESSAGE_BODY_SCAN_START;
  return(CRLF);
}

<MESSAGE_BODY_SCAN_START><<EOF>> {
  printf("End of File\n");  
  BEGIN INITIAL;  
  return(EOF);
}

<MESSAGE_BODY_SCAN_START>{CRLF} {
  printf("End of File\n");
  return(CRLF);
}

<MESSAGE_BODY_SCAN_START>. {
  if('\r' == *yytext)
  {
    BEGIN INITIAL;
    printf("\n 11. Inside Body ");
    return(STRING);
  }
  printf("\n Inside Body ");
}

<MESSAGE_BODY_SCAN_START>"\n" {
  printf("End of File\n");
  BEGIN INITIAL;
  return(STRING);
}

%%
