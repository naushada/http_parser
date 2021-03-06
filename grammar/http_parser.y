%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "http_parser.tab.h"
#include "http_parser.yy.h"

int yyerror(yyscan_t yyscanner, const char *s);
%}

/*! Copies this piece of code verbatim in header file*/
%code requires {
#include "__http.h"
typedef void *yyscan_t;
}

%union {
  http_message_t *message;
  http_qs_t      *request_line;
  http_header_t  *header_line;
  unsigned char  *str;
  unsigned int   offset;
}

/*! tokens are looked in lex file for pattern matching*/
%token <str> STRING HTTP_METHOD HTTP_VERSION QS RESOURCE CRLF SPACE
%token <str> REASON_PHRASE COLON
%token <str> PARAM VALUE
%token <int> STATUS_CODE

%type <request_line> request_URI 
%type <header_line> mime_header 
%type <header_line> mime_headers 
%type <message> generic_message
%type <message> http_message
%type <message> http_messages
%type <str> URI
%type <str> request_line 
%type <str> response_line 
%type <str> message_body 
%type <str> delimeter 

%define parse.error verbose
%define parse.lac full
/*! For re-entrant parser*/
%define api.pure full
%param {yyscan_t yyscanner}

/*! Starting point of the Grammar*/
/*%start generic_message*/

%start http_message


%%

/*! defining Grammar Rule*/
generic_message
  : http_messages
  ;

/*! start_line grammar definition*/

http_messages
  : http_messages http_message     {printf("request line %s\n", $1);}
  | %empty
  ;

 /* | http_message message_header   {printf("Response line is %s\n", $1);}
  | CRLF                          {printf("http message Header CRLF\n");}
  | CRLF message_body
  */

http_message
  : request_line mime_headers    {printf("Value of Mime Heade is %s", $2);}
  | request_line 
  | response_line mime_headers
  | response_line
  | mime_headers message_body
  | mime_headers
  ;

message_body
  : %empty
  | STRING
  ; 

mime_headers
  : %empty
  | mime_headers mime_header
  ;

mime_header
  : PARAM SPACE VALUE  {printf("Mime Header %s %s", $1, $3);}
  | %empty
  | CRLF
  ;

delimeter
  : ':'          {printf("delimeter is \":\"");}
  ;
request_line
  : HTTP_METHOD SPACE request_URI SPACE HTTP_VERSION CRLF {printf("\n$1 %s\n$5 %s \n", $1, $5);}
  ;

response_line
  : HTTP_VERSION SPACE STATUS_CODE SPACE STRING CRLF
  ;

request_URI
  : '*'    {__http_process_options();}
  | '/'    {__http_process_default_uri();}
  | URI    {printf("Got URI");}
  ;

URI
  : RESOURCE '?' QS { __http_process_qs($1, $3);}
  ;

%%

int yyerror(yyscan_t scanner, const char *s) {
  printf( "%s:%d Error: %s \n " , __FILE__, __LINE__,s);
  return(0);
}
