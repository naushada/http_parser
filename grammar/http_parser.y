%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "http_parser.tab.h"
#include "http_parser.yy.h"

int yyerror(yyscan_t yyscanner, const char *s);
http_message_t *__PMessage;
%}

/*! Copies this piece of code verbatim in header file*/
%code requires {
#include "shahada.h"
typedef void *yyscan_t;
}

%union {
  http_message_t *message;
  http_qs_t      *request_line;
  http_headers_t *http_headers;
  char           *pField;
  char           *pValue;
  char           *str;
}

/*! tokens are looked in lex file for pattern matching*/
%token <str> STRING HTTP_METHOD HTTP_VERSION QS RESOURCE CRLF SPACE
%token <pField>  PARAM
%token <pValue>  VALUE
%token <int> STATUS_CODE

%type <request_line> request_URI 
%type <http_headers> mime_headers 
%type <message> http_message
%type <str> URI
%type <request_line> request_line 
%type <str> response_line 
%type <str> message_body 

%define parse.error verbose
%define parse.lac full
/*! For re-entrant parser*/
%define api.pure full
%param {yyscan_t yyscanner}

/*! Starting point of the Grammar*/
%start input

%%

input
  : http_message  {__PMessage = $1;__httpDisplayMimeHeader($1);}
  ;

http_message
  : request_line     {printf("Value of Mime Header is %s\n", $1);}
  | request_line mime_headers {$$ = __httpMessage($1, $2);}
  | response_line
  | response_line mime_headers
  | mime_headers message_body {fprintf(stderr, "\n[Naushad] 2.http_message");}
  ;

message_body
  : %empty            {printf("HTTP Body Ends\n");}
  | STRING CRLF
  ; 

mime_headers
  : PARAM SPACE VALUE CRLF                {$$ = __httpInsertMimeHeader(NULL, $1, $3);} 
  | mime_headers PARAM SPACE VALUE CRLF   {$$ = __httpInsertMimeHeader($1, $2, $4);}
  | CRLF message_body       {fprintf(stderr, "\n HTTP Body Starts\n");}
  ;

request_line
  : HTTP_METHOD SPACE request_URI SPACE HTTP_VERSION CRLF {$$ = __httpRequestLine($1, $3, $5);free($1);free($3);free($5);}
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
