local ffi = require('ffi')
local lex = ffi.load('./lexer.so')

ffi.cdef [[

typedef struct __sFILE FILE;

typedef enum {
    TEOF,
    TUNK,
    TWord,
    TIONumber,
    TNewLine,
    TAnd,
    TLess,
    TGreat,
    TDLess,
    TDGreat,
    TLessAnd,
    TGreatAnd,
    TLessGreat,
    TDLessDash,
} Type;

struct Token {
	char *text;
	Type type;
};

void lexer_new(FILE *);
struct Token * lexer_next(void);

]]


ffi.cdef [[
int fprintf (FILE * stream, const char * format, ... );
]]

local f = io.tmpfile()
ffi.C.fprintf(f, "<&")

f:seek("set", 0)
lex.lexer_new(f)

local token = lex.lexer_next()
print(ffi.string(token.text))

f:close()
