#include <stdio.h>
#include "http_parser.tab.h"
#include "http_parser.yy.h"
#include "shahada.h"

http_message_t *__httpMessage(http_qs_t *reqLine, 
                              http_headers_t *headers,
                              http_body_t *body)
{
  http_message_t *__httpReq = NULL;
  __httpReq = (http_message_t *)malloc(sizeof(http_message_t));
  memset((void *)__httpReq, 0, sizeof(http_message_t));

  __httpReq->http_req     = reqLine;
  __httpReq->http_headers = headers;
  __httpReq->http_body    = body;

  return(__httpReq);
}

http_body_t *__httpInsertBody(http_body_t *head, char *body)
{
  http_body_t *tmp = NULL;
  tmp = (http_body_t *)malloc(sizeof(http_body_t));
  memset((void *)tmp, 0, sizeof(http_body_t));

  tmp->http_body = strdup(body);
  tmp->body_len = strlen(body);
  tmp->next = NULL;

  if(!head)
  {
    return(tmp);
  }

  http_body_t *m;
  for(m = head; m->next; m = m->next) ;

  m->next = tmp;    
  return(head);
}

/*
 * @brief:
 * @param 
 * @param 
 * @param 
 * @return 
 * */
http_qs_t *__httpRequestLine(char *pHttpMethod, 
                             char *pUri, 
                             char *pHttpVersion)
{
  http_qs_t *__pReq = NULL;

  fprintf(stderr, "pHttpMethod %s pUri %s pHttpVersion %s",
          pHttpMethod, pUri, pHttpVersion);

  struct __http_method_t __httpMethodArr[] = 
  {
    {OPTIONS, "OPTIONS", 7},
    {GET,     "GET",     3},
    {HEAD,    "HEAD",    4},
    {POST,    "POST",    4},
    {PUT,     "PUT",     3},
    {DELETE,  "DELETE",  6},
    {TRACE,   "TRACE",   5},
    {CONNECT, "CONNECT", 7}
  };

  struct __http_version_t __httpVersionArr[] =
  {
    {HTTP1dot0, "HTTP/1.0", 8},
    {HTTP1dot1, "HTTP/1.1", 8},
    {HTTP2dot0, "HTTP/2.0", 8}
  };

  do 
  {
    if(!pHttpMethod)
    {
      /*Debug log to be added.*/  
      break;    
    }

    if(!pUri)
    {
      /*Debug log to be added.*/  
      break;    
    }

    if(!pHttpVersion)
    {
      /*Debug log to be added.*/  
      break;
    }

    __pReq = (http_qs_t *)malloc(sizeof(http_qs_t));
    if(!__pReq)
    {
      /*Debug Message to be added.*/  
      break;
    }

    memset((void *)__pReq, 0, sizeof(http_qs_t));
   
    /*Translating HTTP Method.*/
    int idx = 0;
    for(idx = 0; idx <= CONNECT; idx++)
    {
      if(!strncmp(pHttpMethod, __httpMethodArr[idx].pHttpMethodStr, __httpMethodArr[idx].strLen))
      {
        __pReq->method = __httpMethodArr[idx].httpMethod;
        break;
      }
    }

    /*Translating HTTP Verion*/
    for(idx = 0; idx <= HTTP2dot0; idx++)
    {
      if(!strncmp(pHttpVersion, __httpVersionArr[idx].pVersionStr, __httpVersionArr[idx].strLen))
      {
        __pReq->version = __httpVersionArr[idx].httpVersion;
        break;
      }
    }

    /*Copying URI*/
    memset((void *)__pReq->resource_name, 0, sizeof(__pReq->resource_name));
    strncpy(__pReq->resource_name, pUri, strlen(pUri));

  }while(0);

  return(__pReq);
}

http_headers_t *__httpInsertMimeHeader(http_headers_t *headers, char *field, char *value)
{
  return __httpAddMimeHeader(headers, __httpNewMimeHeader(field, value));
}

http_headers_t *__httpAddMimeHeader(http_headers_t *headers, http_header_t *newNode)
{
  http_headers_t *tmp = (http_headers_t*)malloc(sizeof(http_headers_t));
  memset((void *)tmp, 0, sizeof(http_headers_t));

  tmp->header = newNode;
  tmp->next = NULL;

  if(!headers) 
  {
    fprintf(stderr, "\n(headers is NULL - Returning First Header field %s value %s\n", tmp->header->field, tmp->header->value);  
    return tmp;
  }

  http_headers_t *m;
  for(m = headers; m->next; m = m->next) {}
    m->next = tmp;

  return headers;
}

http_header_t *__httpNewMimeHeader(char *pMimeFieldName, 
                                   char *pMimeFieldValue)
{
  http_header_t *fNode = NULL;

  do 
  {
    fNode = (http_header_t*)malloc(sizeof(http_header_t));
    
    if(!fNode)
    {
      /*Add the debug log*/
      break;  
    }

    memset((void *)fNode, 0, sizeof(http_header_t));
    fNode->field = strdup(pMimeFieldName);
    fNode->value = strdup(pMimeFieldValue);
    fprintf(stderr, "\nfield %s value %s\n", fNode->field, fNode->value);
    free(pMimeFieldName);
    free(pMimeFieldValue);
    break;

  } while(0);

  return(fNode);
}

void __httpDisplayMimeHeader(http_message_t *pHttpMessage)
{
  do 
  {
    if(!pHttpMessage)
    {
      /*Add the debug log.*/
      break;
    }
   
    http_headers_t *tmpHeader = pHttpMessage->http_headers;
    while(tmpHeader)
    {
      fprintf(stderr, "Field Name: %s Value: %s\n", tmpHeader->header->field, tmpHeader->header->value);
      tmpHeader = tmpHeader->next;
    }

  }while(0);
}

int __http_process_request(unsigned char *HTTP_method, unsigned char *HTTP_version)
{
  fprintf(stderr, "[%s:%d Value of method %s Version %s\n", 
                  __func__, __LINE__,HTTP_method, HTTP_version);
  return(0);		
}

int __http_process_qs(unsigned char *pResource, unsigned char *pQs)
{
  fprintf(stderr, "[%s:%d] resource %s qs %s\n", 
					 __func__, __LINE__, pResource, pQs);
  return(0);		
}

http_message_t *http_init(void)
{
  http_message_t *pHttpMsg = (http_message_t *)malloc(sizeof(http_message_t));
  if(pHttpMsg)
  {
    memset((void *)pHttpMsg, 0, sizeof(http_message_t));
    fprintf(stderr, "Memory is allocated successfully\n");				
    return(pHttpMsg);				
  }

  return(NULL);

}/*http_init*/

int __http_process_default_uri(void)
{
  fprintf(stderr, "[%s:%d] Default URI \n", __func__, __LINE__);
  return(0);		
}

http_message_t *__http_parser_ex(char *pIn) 
{
  yyscan_t yyscanner;
  extern http_message_t *__PMessage;

  if(yylex_init(&yyscanner))
  {
    fprintf(stderr, "%s:%d initialization to scanner failed\n", __FILE__, __LINE__);
    return((http_message_t *)0);
  }

  YY_BUFFER_STATE buff = pIn ? yy_scan_string(pIn, yyscanner) : 0;

  /*! Upon success, yyparse returns 0 and 1 upon failure.*/
  if(yyparse(yyscanner))
  {
    fprintf(stderr, "%s:%d yyparse failed\n", __FILE__, __LINE__);
    return((http_message_t *)0);    
  }

  yy_delete_buffer(buff, yyscanner);
  yylex_destroy(yyscanner);

  return(__PMessage);

}

int __http_process_options(void)
{
  fprintf(stderr,"Processing options");
	return 0;
}




