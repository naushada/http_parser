#include <stdio.h>
#include "http_parser.tab.h"
#include "http_parser.yy.h"
#include "shahada.h"

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




