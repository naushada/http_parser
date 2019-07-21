#include <stdio.h>
#include "__http.h"


int yydebug = 1;
int main(int argc, char **argv) {
  /*! Read input from File now.*/
  char buff[2048] = "GET / HTTP/1.1\r\n"
                    "Host: 10.10.10.1\r\n"
                    "Content-Length: 101\r\n"
                    "\r\n\r\n";
  //char buff[2048] = "HTTP/1.1 200 OK\r\nGET / HTTP/1.1\r\n";
  unsigned char *http_value;
  if ((http_value = __http_parser_ex(buff))) 
  {
  } 
  else 
  {
    printf("%s:%d HTTP Parser error!\n", __FILE__, __LINE__);
  }

  return 0;
}
