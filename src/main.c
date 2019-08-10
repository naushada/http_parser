#include <stdio.h>
#include "shahada.h"


int yydebug = 1;
int main(int argc, char **argv) {
  /*! Read input from File now.*/
  char buff[2048] = "GET / HTTP/1.1\r\n"
                    "Host: 10.10.10.1\r\n"
                    "Content-Length: 101\r\n"
                    "Content-Type: json; txt/5.0\r\n"
                    "\r\n\r\n"
                    "a=b&c=d\r\n";

  return (__http_parser_ex(buff));
}
