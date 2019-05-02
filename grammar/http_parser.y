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
  unsigned char *str;
}

/*! tokens are looked in lex file for pattern matching*/
%token <str> STRING HTTP_METHOD HTTP_VERSION QS RESOURCE CRLF SPACE
%token <str> REASON_PHRASE
%token <int> STATUS_CODE

%type <request_line> request_URI 
%type <header_line> message_header 
%type <message> generic_message
%type <message> http_message
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
%start generic_message


%%

/*! defining Grammar Rule*/
generic_message
  : http_message
  ;

/*! start_line grammar definition*/
message_header
  : %empty
  | STRING ':' SPACE STRING CRLF
  | CRLF                         {printf("message Body Starts\n");}
  ;

http_message
  : request_line message_header  {printf("request line %s\n", $1);}
  | response_line message_header {printf("Response line is %s\n", $1);}
  | message_header message_body
  | CRLF                         {printf("http message Header CRLF\n");}
  ;

message_body
  : %empty
  | STRING CRLF
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
