//#include "http_parser.tab.h"
//#include "http_parser.yy.h"
#include <stdio.h>
#include "__http.h"

int main(int argc, char **argv) {
  /*! Read input from File now.*/
  char buff[2048] = "GET / HTTP/1.1\r\nHTTP/1.1 200 OK\r\n";
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
