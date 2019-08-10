#ifndef __HTTP_H__
#define __HTTP_H__
/*!
	* @brief HTTP Data structure declaration and their definition
	* @dated 20-Apr-2019
	* */

#define __HTTP_MAX_URI_SIZE 512

typedef enum
{
  OPTIONS,
  GET,
  HEAD,
  POST,
  PUT,
  DELETE,
  TRACE,
  CONNECT,

}http_method_t;

typedef enum
{
  HTTP1dot0 = 1,
  HTTP1dot1,
  HTTP2dot0
}http_version_t;

typedef struct
{
  unsigned int status_code;
  unsigned char *status_str;

}http_status_t;

struct __http_method_t 
{
  http_method_t httpMethod;
  char *pHttpMethodStr;
  unsigned char strLen;
};

struct __http_version_t
{
  http_version_t httpVersion;
  char *pVersionStr;
  unsigned char strLen;
};

typedef struct http_header 
{
  char *field;
  char *value;
}http_header_t;

struct http_headers
{
  http_header_t *header;  
  struct http_headers *next;
};

struct qs_param
{
  unsigned char *name;
  unsigned char *value;
  struct qs_param *next;
};

typedef struct qs_param qs_param_t;

struct http_qs
{
  http_method_t method;
  http_version_t version;
  char resource_name[__HTTP_MAX_URI_SIZE];
  qs_param_t qs_param;
  
};

struct http_body
{
  int  body_len;								
  char *http_body;
  struct http_body *next;		
};

typedef struct http_qs http_qs_t;
typedef struct http_headers http_headers_t;
typedef struct http_body http_body_t;

struct http_req
{
  http_qs_t      *http_req;
  http_headers_t *http_headers;
  http_body_t    *http_body;

};

typedef struct http_req http_message_t;

int __http_process_request(unsigned char *HTTP_method, unsigned char *HTTP_version);

int __http_process_qs(unsigned char *pResource, unsigned char *pQs);

int __http_process_default_uri(void);
int __http_process_options(void);

http_message_t *__http_parser_ex(char *pIn);

http_message_t *http_init(void);

http_qs_t *__httpRequestLine(char *pHttpMethod, 
                             char *pUri, 
                             char *pHttpVersion);

http_header_t *__httpNewMimeHeader(char *pMimeFieldName, 
                                   char *pMimeFieldValue);

void __httpDisplayMimeHeader(http_message_t *pHttpMessage);

http_headers_t *__httpAddMimeHeader(http_headers_t *headers, http_header_t *newNode);
http_message_t *__httpMessage(http_qs_t *reqLine, http_headers_t *header, http_body_t *body);
http_headers_t *__httpInsertMimeHeader(http_headers_t *headers, 
                                       char *field, 
                                       char *value);

http_body_t *__httpInsertBody(http_body_t *head, char *body);

#endif /*__HTTP_H__*/
