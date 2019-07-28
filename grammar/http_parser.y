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
#include "shahada.h"
typedef void *yyscan_t;
}

%union {
  http_message_t *message;
  http_qs_t      *request_line;
  http_header_t  *header_line;
  char  *pField;
  unsigned int   fieldNameLen;
  char  *pValue;
  unsigned int   fieldValueLen;
  unsigned char  *str;
}

/*! tokens are looked in lex file for pattern matching*/
%token <str> STRING HTTP_METHOD HTTP_VERSION QS RESOURCE CRLF SPACE
%token <pField>  PARAM
%token <pValue>  VALUE
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

%define parse.error verbose
%define parse.lac full
/*! For re-entrant parser*/
%define api.pure full
%param {yyscan_t yyscanner}

/*! Starting point of the Grammar*/
%start http_message

%%

http_message
  : request_line mime_headers    {printf("Value of Mime Header is %s", $2);}
  | request_line 
  | response_line mime_headers
  | response_line
  | mime_headers message_body
  | mime_headers
  ;

message_body
  : %empty            {printf("\nHTTP Body Ends");}
  | STRING
  ; 

mime_headers
  : %empty
  | mime_headers mime_header
  ;

mime_header
  : PARAM SPACE VALUE  {fprintf(stderr, "[Naushad]$1 %s $2 %s", $1, $2);unsigned int xx = 6; __httpMimeHeader($1, $2, &xx);}
  | %empty             {fprintf(stderr, "\nMime Header End");}
  | CRLF               {fprintf(stderr, "HTTP Body Starts\n");}
  ;

request_line
  : HTTP_METHOD SPACE request_URI SPACE HTTP_VERSION CRLF {__httpRequestLine($1, $3, $5);}
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
