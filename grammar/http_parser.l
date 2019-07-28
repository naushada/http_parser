%{
#include <stdio.h>
#include <stdlib.h>
#include "http_parser.tab.h"								
#include "shahada.h"

extern int yyerror(yyscan_t yyscanner, const char *s);
unsigned int idx = 0;

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
%x STRING MIME_PARAM_SCAN MIME_PARAM_VALUE_SCAN 
%x HTTP_BODY_SCAN MESSAGE_BODY_SCAN_START MIME_DELIMITER 
%x MIME_VALUE_DELIMITER

DIGIT                [0-9]
INTEGER              -?(0|[1-9]{DIGIT}*)
NUMBER               {INTEGER}\.{DIGIT}+
ALPHA                [a-zA-Z]
ALPHANUM             [a-zA-Z0-9]
HEX                  [0-9a-fA-F]
CRLF                 [\r\n]
SPACE                [ ]
PROTOCOL             (HTTP)\/{DIGIT}\.{DIGIT} 
METHOD               (OPTIONS|GET|HEAD|POST|PUT|DELETE|TRACE|CONNECT)
STR                  (\"|\')([ALPHA]([ALPHANUM][\.\/\+\-\%\*])*:?[^\r\n])(\"|\')	
MIME_PARAM_NAME      [ALPHA]([ALPHANUM][\-])*
 /*Any Character except : which is the delimeter of FIELD*/
HEADER_FIELD         [^:]
DELIMITER            [:][ ]
 /*Any character except \r*/
HEADER_VALUE         [^\r]
BODY_START           {CRLF}{2}
CHAR_EXCEPT_NEWLINE  .
NEWLINE              "\n"


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
  printf("MIME Header Starts. \n");
  BEGIN MIME_PARAM_SCAN;

  /*! End of line */
  return CRLF;								
}

<INITIAL><<EOF>> {
  printf("Parsed successfully\n");
  return EOF;
}

 /*!end-delimiter for mime-header i.e. \r\n\r\n*/
<MIME_PARAM_SCAN>{BODY_START} {
  fprintf(stderr, "[Naushad] HTTP Body Starts\n");  
  BEGIN MESSAGE_BODY_SCAN_START;
  return(CRLF);
}

<MIME_PARAM_SCAN>{HEADER_FIELD}+ {
  printf("\nMIME_PARAM_NAME %s\n", yytext);
  yylval->pField = strdup(yytext);
  BEGIN MIME_DELIMITER;
  return(PARAM);
}

<MIME_DELIMITER>{DELIMITER}+ {
  BEGIN MIME_PARAM_VALUE_SCAN;
  return(SPACE);
}

<MIME_PARAM_VALUE_SCAN>{HEADER_VALUE}+ {
  printf("\nPARAM Value is %s\n", yytext);
  BEGIN MIME_VALUE_DELIMITER;
  yylval->pValue = strdup(yytext);
  return(VALUE);
}

<MIME_VALUE_DELIMITER>{CRLF} {
  BEGIN MIME_PARAM_SCAN;
  return(CRLF);
}


 /*! move to initial stae upon receipt of EOF - End-of-File*/
<MESSAGE_BODY_SCAN_START><<EOF>> {
  BEGIN INITIAL;  
  return(EOF);
}

 /*! HTTP Body ends with single CRLF*/
<MESSAGE_BODY_SCAN_START>{CRLF} {
  /*!move to INITIAL state.*/    
  BEGIN INITIAL;  
  return(CRLF);
}

<MESSAGE_BODY_SCAN_START>{NEWLINE} {
  BEGIN INITIAL;
  return(STRING);
}

<MESSAGE_BODY_SCAN_START>{CHAR_EXCEPT_NEWLINE}+ {
  return(STRING);
}


%%
