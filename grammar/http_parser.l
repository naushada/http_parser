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
%x STRING MIME_PARAM_SCAN MIME_PARAM_VALUE_SCAN HTTP_BODY_SCAN MESSAGE_BODY_SCAN_START

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
  printf("End with CRLF \n");						
  /*! End of line */
  return CRLF;								
}

<INITIAL><<EOF>> {
  printf("Parsed successfully\n");
  return EOF;
}

 /*Parsing MIME Header Field*/
<INITIAL>{MIME_PARAM_NAME}+ {
  printf("MIME_FIELD is %s\n",yytext);
  BEGIN MIME_PARAM_SCAN;
}

 /*! scanning mime-field name which ends with :*/
<MIME_PARAM_SCAN>{CHAR_EXCEPT_NEWLINE} {
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

 /*!mime-param-value scan- which starts with preceeding SPACE*/
<MIME_PARAM_VALUE_SCAN>{SPACE}+ {
  return(SPACE);
}

 /*! scanning mime-value which ends with \r\n*/
<MIME_PARAM_VALUE_SCAN>{CHAR_EXCEPT_NEWLINE} {
  if('\r' == *yytext)
  {
    /*!mime value scanning completes*/    
  }
  /*!Collecting individual character*/
  printf("\nMime Valus is %s\n", yytext);
}

 /*!Check for new mime-header.*/
<MIME_PARAM_VALUE_SCAN>{NEWLINE} {
  BEGIN MIME_PARAM_SCAN;
  return(VALUE);
}

 /*!end-delimiter for mime-header i.e. \r\n\r\n*/
<MIME_PARAM_SCAN>{BODY_START} {
  BEGIN MESSAGE_BODY_SCAN_START;
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

<MESSAGE_BODY_SCAN_START>{CHAR_EXCEPT_NEWLINE} {
  if('\r' == *yytext)
  {
    printf("\n 11. Inside Body ");
    return(STRING);
  }
  printf("\n Inside Body ");
}

<MESSAGE_BODY_SCAN_START>{NEWLINE} {
  BEGIN INITIAL;
  return(STRING);
}

%%
