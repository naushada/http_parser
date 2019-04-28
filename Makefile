CC = gcc
YACC = bison
LEX = flex
BIN = bin/HTTP
FLAGS =  -O2 -Wall
INC = -I./ -I./inc -I./parser
LINK_LIB = 
OBJS        = obj/main.o obj/__http.o obj/http_parser.tab.o obj/http_parser.yy.o
GENERAT_SRC = parser/http_parser.tab.c parser/http_parser.tab.h parser/http_parser.yy.c parser/http_parser.yy.h


all: build parser/http_parser.yy.c parser/http_parser.tab.c $(BIN)
.PHONY: all

# /* Creates the directory if don't exists */
build:
	@mkdir -p parser
	@mkdir -p obj
	@mkdir -p bin

parser/http_parser.yy.c: grammar/http_parser.l
	$(LEX) $^

parser/http_parser.tab.c: grammar/http_parser.y
	$(YACC) -d -b http_parser $^ -o $@

# /*Creating Shared library i.e. libjson.so */
$(BIN): $(OBJS)
	$(CC) $(FLAGS) -o $@  $^  $(LINK_LIB)

# /* Creating Object files in obj directory from source files */

obj/%.o: src/%.c
	$(CC) $(FLAGS) -c $< -o $@ $(INC)

# /* Creating Object files from source files kept in parser directory. */

obj/%.o: parser/%.c
	$(CC) $(FLAGS) -c $< -o $@ $(INC)

obj/main.o        : inc/__http.h
obj/__http.o        : inc/__http.h parser/http_parser.tab.h parser/http_parser.yy.h
obj/http_parser.tab.o  : parser/http_parser.tab.c parser/http_parser.tab.h
obj/http_parser.yy.o      : parser/http_parser.yy.c parser/http_parser.yy.h

.PHONY: clean
clean:
	rm -f $(BIN) $(OBJS) $(GENERAT_SRC)
	@rm -fr parser
	@rm -fr obj
	@rm -fr bin	
