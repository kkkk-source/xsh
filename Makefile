indent:
	indent -kr src/main.c src/lex.c src/lex.h

build:
	gcc -o main src/main.c src/lex.c -Wall -Werror

debug:
	gcc src/main.c src/lex.c -Wall -Werror -g && gdb main

test: fPIC
	luajit test/lex.lua

fPIC:
	gcc -shared -fPIC -o test/lex.so src/lex.c -Wall -Werror
