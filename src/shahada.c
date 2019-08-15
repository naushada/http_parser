#include <stdio.h>
#include <assert.h>
#include "http_parser.tab.h"
#include "http_parser.yy.h"
#include "shahada.h"

http_message_t *__httpRspMessage(http_status_t *statusLine, 
                                 http_headers_t *headers,
                                 http_body_t *body)
{
      
  http_message_t *__httpRsp = NULL;
  __httpRsp = (http_message_t *)malloc(sizeof(http_message_t));
  assert(__httpRsp != NULL);

  memset((void *)__httpRsp, 0, sizeof(http_message_t));

  __httpRsp->status_line   = statusLine;
  __httpRsp->http_headers  = headers;
  __httpRsp->http_body     = body;

  return(__httpRsp);
}

http_message_t *__httpReqMessage(http_qs_t *reqLine, 
                                 http_headers_t *headers,
                                 http_body_t *body)
{
  http_message_t *__httpReq = NULL;
  __httpReq = (http_message_t *)malloc(sizeof(http_message_t));

  /*assert when __httpReq ins equal to NULL.*/
  assert(__httpReq != NULL);

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
  /*assert when tmp is equal to NULL.*/
  assert(tmp != NULL);

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
http_status_t *__httpStatusLine(char *pHttpVersion, 
                                int statusCode, 
                                char *pReasonPhrase)
{
  http_status_t *__pReq = NULL;

  fprintf(stderr, "pHttpVersion %s statusCode %d pReasonPhrase %s",
          pHttpVersion, statusCode, pReasonPhrase);

  struct __http_version_t __httpVersionArr[] =
  {
    {HTTP1dot0, "HTTP/1.0", 8},
    {HTTP1dot1, "HTTP/1.1", 8},
    {HTTP2dot0, "HTTP/2.0", 8}
  };

  do 
  {
    if(!pHttpVersion)
    {
      /*Debug log to be added.*/  
      break;    
    }

    if(!pReasonPhrase)
    {
      /*Debug log to be added.*/  
      break;    
    }

    __pReq = (http_status_t *)malloc(sizeof(http_status_t));
    assert(__pReq != NULL); 

    memset((void *)__pReq, 0, sizeof(http_status_t));

    /*Translating HTTP Verion*/
    int idx;
    for(idx = 0; idx <= HTTP2dot0; idx++)
    {
      if(!strncmp(pHttpVersion, __httpVersionArr[idx].pVersionStr, __httpVersionArr[idx].strLen))
      {
        __pReq->protocol = __httpVersionArr[idx].httpVersion;
        break;
      }
    }

    free(pHttpVersion);
    __pReq->status_code = statusCode;
    __pReq->reasonPhrase = strdup(pReasonPhrase);
    free(pReasonPhrase);

  }while(0);

  return(__pReq);
}

/*
 * @brief:
 * @param 
 * @param 
 * @param 
 * @return 
 * */
http_qs_t *__httpRequestLine(char *pHttpMethod, 
                             qs_param_ttt *pUri, 
                             char *pHttpVersion)
{
  http_qs_t *__pReq = NULL;

  fprintf(stderr, "pHttpMethod %s pUri %s pHttpVersion %s",
          pHttpMethod, pUri->resource_name, pHttpVersion);

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
    /*assert when __pReq is equal to NULL.*/
    assert(__pReq != NULL); 

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

    __pReq->qs_param = pUri;
    fprintf(stderr, "\nResource Name is %s\n", __pReq->qs_param->resource_name);
    free(pUri);

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
  assert(tmp != NULL);

  memset((void *)tmp, 0, sizeof(http_headers_t));

  tmp->header = newNode;
  tmp->next = NULL;

  if(!headers) 
  {
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
    assert(fNode != NULL); 

    memset((void *)fNode, 0, sizeof(http_header_t));
    fNode->field = strdup(pMimeFieldName);
    fNode->value = strdup(pMimeFieldValue);
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

qs_param_ttt *__http_process_qs(char *pResource, qs_param_t *pQs)
{
  fprintf(stderr, "[%s:%d] resource %s \n", 
					 __func__, __LINE__, pResource);

  qs_param_t *head = NULL;
  qs_param_ttt *qs_param = (qs_param_ttt *)malloc(sizeof(qs_param_ttt));
  /*Continue as long as qs_param is not NULL.*/
  assert(qs_param != NULL);

  do 
  {
    if(!pQs)
    {
      /*Only resource name is present.*/ 
      qs_param->resource_name = strdup(pResource);
      qs_param->qsParam = pQs;
      fprintf(stderr, "%s:%d resource_name %s", __FILE__, __LINE__,qs_param->resource_name);
      free(pResource);
      break;
    }

    if(!qs_param->qsParam)
    {
      qs_param->qsParam = pQs;
      break;
    }

    /*Insert QS at the End.*/
    for(head = qs_param->qsParam ;head->next; head = head->next) ;

    head->next = pQs;

  }while(0);

  return(qs_param);		
}

qs_param_ttt *__httpInsertQsParam(qs_param_ttt *qsParam, 
                                  char *param, 
                                  char *value)
{
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

void *__http_parser_ex(char *pIn) 
{
  yyscan_t yyscanner;
  extern http_message_t *__PMessage;

  if(yylex_init(&yyscanner))
  {
    fprintf(stderr, "%s:%d initialization to scanner failed\n", __FILE__, __LINE__);
    return((void *)0);
  }

  YY_BUFFER_STATE buff = pIn ? yy_scan_string(pIn, yyscanner) : 0;

  /*! Upon success, yyparse returns 0 and 1 upon failure.*/
  if(yyparse(yyscanner))
  {
    fprintf(stderr, "%s:%d yyparse failed\n", __FILE__, __LINE__);
    return((void *)0);    
  }

  yy_delete_buffer(buff, yyscanner);
  yylex_destroy(yyscanner);

  return((void *)__PMessage);
}

int __http_process_options(void)
{
  fprintf(stderr,"Processing options");
	return 0;
}

/*********************************************************
 *
 * Exposed API for application.
 *
 ********************************************************/
char *shahadaGetFieldValue(char *field_name, void *pMsg)
{
  http_message_t *msg = (http_message_t *)pMsg;  
  http_headers_t *head = msg ? msg->http_headers: NULL; 
  char *fieldValue = NULL;

  do 
  {    
    if(!head)
    {
      fprintf(stderr, "Pointer to http_message_t is NULL");
      break;
    }

    while(head)
    {
      if(!strncmp(field_name, head->header->field, strlen(field_name)))
      {
        fieldValue = strdup(head->header->value);
        break;
      }
      head = head->next;
    }

  }while(0);

  return(fieldValue);
}

int shahadaGetMethod(void *msg)
{
  http_message_t *pMsg = (http_message_t *)msg;  
  http_qs_t *head = pMsg ? pMsg->http_req: NULL;
  return(head ? (int)head->method :-1);
}

int shahadaGetProtocol(void *msg)
{
  http_message_t *pMsg = (http_message_t *)msg;  
  http_qs_t *head = pMsg ? pMsg->http_req: NULL;
  return(head ? (int)head->version :-1);
}

char *shahadaGetUri(void *msg)
{
  http_message_t *pMsg = (http_message_t *)msg;  
  char *pUri = NULL;
  http_qs_t *head = pMsg ? pMsg->http_req: NULL;
  assert(head != NULL);

  pUri = strdup(head->qs_param->resource_name);
  fprintf(stderr, "%s:%d Uri is %s\n", __FILE__, __LINE__, head->qs_param->resource_name);
  return(pUri);
}

char *shahadaGetQsParamValue(char *qsParamName, void *msg)
{
  http_message_t *pMsg = (http_message_t *)msg;  
  char *pQsParam = NULL;
  qs_param_t *head = pMsg ? pMsg->http_req->qs_param->qsParam: NULL;
 
  assert(qsParamName != NULL);

  if(!head)
  {
     return(pQsParam);    
  }

  while(head)
  {
    if(!strncmp(qsParamName, head->name, strlen(qsParamName)))
    {
      pQsParam = strdup(head->value);
      break;
    }

    head = head->next;
  }

  return(pQsParam);
}

int shahadaGetStatusCode(void *msg)
{
  http_message_t *pMsg = (http_message_t *)msg;  
  http_status_t *head = pMsg ? pMsg->status_line: NULL;
  return(head ? (int)head->status_code : -1);
}

char *shahadaGetReasonPhrase(void *msg)
{
  http_message_t *pMsg = (http_message_t *)msg;  
  char *pReasonPhrase = NULL;
  http_status_t *head = pMsg ? pMsg->status_line: NULL;
  
  if(!head)
  {
     return(pReasonPhrase);    
  }

  pReasonPhrase = strdup(head->reasonPhrase);
  return(pReasonPhrase);
}


