local ffi = require('ffi')
local lex = ffi.load('./lexer.so')

ffi.cdef [[

typedef struct __sFILE FILE;
typedef struct __sLex Lex;

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

typedef struct __sToken {
    char * text;
    Type type;
} Token;

Lex * lex_make(void);
void lex_read(const char *);
Token *lex_next(void);

]]

local tests = {
	{input = "0", want = "0"},
	{input = "1", want = "1"},
	{input = "2", want = "2"},
	{input = "3", want = "3"},
	{input = "4", want = "4"},
	{input = "5", want = "5"},
	{input = "6", want = "6"},
	{input = "7", want = "7"},
	{input = "8", want = "8"},
	{input = "9", want = "9"},
	{input = "  0  ", want = "0"},
	{input = "  1  ", want = "1"},
	{input = "  2  ", want = "2"},
	{input = "  3  ", want = "3"},
	{input = "  4  ", want = "4"},
	{input = "  5  ", want = "5"},
	{input = "  6  ", want = "6"},
	{input = "  7  ", want = "7"},
	{input = "  8  ", want = "8"},
	{input = "  9  ", want = "9"},
	{input = "1234567890", want = "1234567890"},
	{input = "  1234567890  ", want = "1234567890"},
	{input = "<", want = "<"},
	{input = ">", want = ">"},
	{input = "<&", want = "<&"},
	{input = ">&", want = ">&"},
	{input = "<<", want = "<<"},
	{input = ">>", want = ">>"},
	{input = "  <  ", want = "<"},
	{input = "  >  ", want = ">"},
	{input = "  <&  ", want = "<&"},
	{input = "  >&  ", want = ">&"},
	{input = "  <<  ", want = "<<"},
	{input = "  >>  ", want = ">>"},
}

for _, tt in pairs(tests) do
	lex.lex_make()
	lex.lex_read(tt.input)

	local t = lex.lex_next()
	local got = ffi.string(t.text)
	
	if got ~= tt.want then
		print(string.format("got=%s, want=%s.", got, tt.want))
	end
end
