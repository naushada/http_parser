#include <stdio.h>
#include "http_parser.tab.h"
#include "http_parser.yy.h"
#include "shahada.h"

http_message_t *pHttpMessageG = NULL;

/*
 * @brief:
 * @param 
 * @param 
 * @param 
 * @return 
 * */
void __httpRequestLine(unsigned char *pHttpMethod, 
                       unsigned char *pUri, 
                       unsigned char *pHttpVersion)
{
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

    pHttpMessageG = (http_message_t *)malloc(sizeof(http_message_t));
    if(!pHttpMessageG)
    {
      /*Debug Message to be added.*/  
      break;
    }

    memset((void *)pHttpMessageG, 0, sizeof(http_message_t));
   
    /*Translating HTTP Method.*/
    int idx = 0;
    for(idx = 0; idx <= CONNECT; idx++)
    {
      if(!strncmp(pHttpMethod, __httpMethodArr[idx].pHttpMethodStr, __httpMethodArr[idx].strLen))
      {
        pHttpMessageG->http_req.method = __httpMethodArr[idx].httpMethod;
        break;
      }
    }

    /*Translating HTTP Verion*/
    for(idx = 0; idx <= HTTP2dot0; idx++)
    {
      if(!strncmp(pHttpVersion, __httpVersionArr[idx].pVersionStr, __httpVersionArr[idx].strLen))
      {
        pHttpMessageG->http_req.version = __httpVersionArr[idx].httpVersion;
        break;
      }
    }

  }while(0);

}

/*
 * @brief 
 * @param 
 * @param 
 * @return 
 * */
void __httpMimeHeader(unsigned char *pMimeFieldName, 
                      unsigned char *pMimeFieldValue, 
                      unsigned int *pMimeValueLen)
{
  do 
  {
    if(!pMimeFieldName || !pMimeFieldValue)
    {
      /*Add debug log.*/
      break;
    }

    if(!pHttpMessageG)
    {
      /*Add debug log.*/
      break;
    }

    if(!pHttpMessageG->http_header.field ||
       !pHttpMessageG->http_header.value)
    {
      pHttpMessageG->http_header.field = (unsigned char *)malloc(strlen((char *)pMimeFieldName) + 1);
      if(!pHttpMessageG->http_header.field)
      {
        /*Add debug log.*/
        break;
      }
      *((char *) memcpy(pHttpMessageG->http_header.field, 
                        pMimeFieldName, 
                        strlen((char *)pMimeFieldName))) = '\0';

      pHttpMessageG->http_header.value = (unsigned char *)malloc(*pMimeValueLen + 1);
      if(!pHttpMessageG->http_header.value)
      {
        /*Add debug log.*/
        break;
      }

      memset((void *)pHttpMessageG->http_header.value, 0, *pMimeValueLen + 1);
      memcpy(pHttpMessageG->http_header.value,
             pMimeFieldValue,
             *pMimeValueLen);
      pHttpMessageG->http_header.next = NULL;
      break;
    }

    /*Go to the end of the linked list.*/
    http_header_t *tmpNode = pHttpMessageG->http_header.next;
    http_header_t *prevNode = NULL;

    while(tmpNode && tmpNode->next)
    {
      prevNode = tmpNode;
      tmpNode = tmpNode->next;    
    }

    tmpNode = (http_header_t *)malloc(sizeof(http_header_t));
    if(!tmpNode)
    {
      /*Add debug log.*/
      break;
    }

    prevNode->next = tmpNode;
    *((char *) memcpy(tmpNode->field, 
                      pMimeFieldName, 
                      strlen((char *)pMimeFieldName))) = '\0';

    tmpNode->value = (unsigned char *)malloc(*pMimeValueLen);
    if(!tmpNode->value)
    {
       /*Add debug log.*/
       break;
    }

    memset((void *)tmpNode->value, 0, *pMimeValueLen);
    memcpy(tmpNode->value,
           pMimeFieldValue,
           *pMimeValueLen);
    tmpNode->next = NULL;

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

unsigned char *__http_parser_ex(char *pIn) 
{
  yyscan_t yyscanner;
  unsigned char *str = NULL;

  if(yylex_init(&yyscanner))
  {
    fprintf(stderr, "%s:%d initialization to scanner failed\n", __FILE__, __LINE__);
    return((unsigned char *)0);
  }

  YY_BUFFER_STATE buff = pIn ? yy_scan_string(pIn, yyscanner) : 0;

  /*! Upon success, yyparse returns 0 and 1 upon failure.*/
  if(yyparse(yyscanner))
  {
    fprintf(stderr, "%s:%d yyparse failed\n", __FILE__, __LINE__);
    return((unsigned char *)0);    
  }

  yy_delete_buffer(buff, yyscanner);
  yylex_destroy(yyscanner);

  return(str);

}

int __http_process_options(void)
{
  fprintf(stderr,"Processing options");
	return 0;
}




