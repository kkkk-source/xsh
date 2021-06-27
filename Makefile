test: fPIC
	luajit test/lexer.lua

fPIC:
	gcc -shared -fPIC -o test/lexer.so src/lexer.c -Wall -Werror

build:
	gcc -o main src/main.c src/lexer.c -Wall -Werror

debug:
	gcc src/main.c src/lexer.c -Wall -Werror -g && gdb main

