indent:
	indent -kr src/main.c src/lex.c src/lex.h src/keyw.c src/parse.c src/parse.h src/keyw.h

build:
	gcc -o main src/main.c src/lex.c src/keyw.c src/parse.c -Wall -Werror

debug:
	gcc -o main src/main.c src/lex.c src/keyw.c src/parse.c -Wall -Werror -g && gdb main

test: fPIC
	luajit test/lex.lua
	luajit test/keyw.lua

fPIC:
	gcc -shared -fPIC -o test/lex.so src/lex.c src/keyw.c -Wall -Werror
	gcc -shared -fPIC -o test/keyw.so src/keyw.c src/lex.c -Wall -Werror
