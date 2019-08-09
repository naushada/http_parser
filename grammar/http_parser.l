%{
#include <stdio.h>
#include <stdlib.h>
#include "http_parser.tab.h"								
#include "shahada.h"

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
%x MIME_PARAM_SCAN MIME_PARAM_VALUE_SCAN 
%x HTTP_BODY_SCAN MESSAGE_BODY_SCAN_START MIME_DELIMITER 
%x MIME_VALUE_DELIMITER

DIGIT                [0-9]
INTEGER              -?(0|[1-9]{DIGIT}*)
NUMBER               {INTEGER}\.{DIGIT}+
ALPHA                [a-zA-Z]
ALPHANUM             [a-zA-Z0-9]
HEX                  [0-9a-fA-F]
CRLF                 (\r\n)
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
BODY_START           (\r\n\r\n\r\n) 
CHAR_EXCEPT_NEWLINE  .
NEWLINE              "\n"


%%


<INITIAL>{METHOD} {
  yylval->str = strdup(yytext); 
  return HTTP_METHOD;
}

<INITIAL>{SPACE} {
  return SPACE;
}

<INITIAL>"*" {
  return('*');		
}

<INITIAL>"/" {
  yylval->str = strdup(yytext);
  return('/');		
}

<INITIAL>{PROTOCOL} {
  yylval->str = strdup(yytext);
  return HTTP_VERSION;
}


<INITIAL>{DIGIT}{3} {
  return STATUS_CODE;
}

<INITIAL>{CRLF} {
  printf("MIME Header Starts. \n");
  BEGIN MIME_PARAM_SCAN;

  /*! End of line */
  return CRLF;								
}

<INITIAL><<EOF>> {
  printf("Parsed successfully\n");
  return EOF;
}

<MIME_PARAM_SCAN><<EOF>> {
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
  yylval->pField = strdup(yytext);
  fprintf(stderr, "\nHeader Field is %s\n", yylval->pField);
  BEGIN MIME_DELIMITER;
  return(PARAM);
}

<MIME_DELIMITER>{DELIMITER}+ {
  BEGIN MIME_PARAM_VALUE_SCAN;
  return(SPACE);
}

<MIME_PARAM_VALUE_SCAN>{HEADER_VALUE}+ {
  BEGIN MIME_VALUE_DELIMITER;
  yylval->pValue = strdup(yytext);
  return(VALUE);
}

<MIME_VALUE_DELIMITER>{BODY_START} {
  BEGIN MESSAGE_BODY_SCAN_START;
  fprintf(stderr, "\nBody Starts now\n");
  return(CRLF);
}

<MIME_VALUE_DELIMITER>{CRLF} {
  BEGIN MIME_PARAM_SCAN;
  fprintf(stderr, "\nMatched CRLF");
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
  fprintf(stderr, "\nEnd of Body\n");
  return(CRLF);
}

<MESSAGE_BODY_SCAN_START>{HEADER_VALUE}+ {
  fprintf(stderr, "\nBody Value is %s\n", yytext);
  yylval->str = strdup(yytext);
  return(lSTRING);
}


%%
