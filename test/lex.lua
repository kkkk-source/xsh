local ffi = require('ffi')
local lex = ffi.load('test/lex.so')

ffi.cdef [[

typedef struct __sFILE FILE;
typedef struct __sLex Lex;

typedef enum {
    TEOF,
    TUNK,
    TIONumber,
    TAnd,
    TLess,
    TGreat,
    TDLess,
    TDGreat,
    TLessAnd,
    TGreatAnd,
} Type;

typedef struct __sToken {
    char * text;
    Type   type;
} Token;

Lex * lex_make(void);
void lex_readfrom(const char *);
Token *lex_next(void);

]]

Type = {
	TEOF = 0,
	TUNK = 1,
	TIONumber = 2,
	TAnd = 3,
	TLess = 4,
	TGreat = 5,
	TDLess = 6,
	TDGreat = 7,
	TLessAnd = 8,
	TGreatAnd = 9,
}

local tests = {
	{input = "0", want = "0", type = Type.TIONumber},
	{input = "1", want = "1", type = Type.TIONumber},
	{input = "2", want = "2", type = Type.TIONumber},
	{input = "3", want = "3", type = Type.TIONumber},
	{input = "4", want = "4", type = Type.TIONumber},
	{input = "5", want = "5", type = Type.TIONumber},
	{input = "6", want = "6", type = Type.TIONumber},
	{input = "7", want = "7", type = Type.TIONumber},
	{input = "8", want = "8", type = Type.TIONumber},
	{input = "9", want = "9", type = Type.TIONumber},
	{input = "1234567890", want = "1234567890", type = Type.TIONumber},
	{input = "&", want = "&", type = Type.TAnd},
	{input = "<", want = "<", type = Type.TLess},
	{input = ">", want = ">", type = Type.TGreat},
	{input = "<&", want = "<&", type = Type.TLessAnd},
	{input = ">&", want = ">&", type = Type.TGreatAnd},
	{input = "<<", want = "<<", type = Type.TDLess},
	{input = ">>", want = ">>", type = Type.TDGreat},

	-- space at the left side
	{input = " 0", want = "0", type = Type.TIONumber},
	{input = " 1", want = "1", type = Type.TIONumber},
	{input = " 2", want = "2", type = Type.TIONumber},
	{input = " 3", want = "3", type = Type.TIONumber},
	{input = " 4", want = "4", type = Type.TIONumber},
	{input = " 5", want = "5", type = Type.TIONumber},
	{input = " 6", want = "6", type = Type.TIONumber},
	{input = " 7", want = "7", type = Type.TIONumber},
	{input = " 8", want = "8", type = Type.TIONumber},
	{input = " 9", want = "9", type = Type.TIONumber},
	{input = " 1234567890", want = "1234567890", type = Type.TIONumber},
	{input = " &", want = "&", type = Type.TAnd},
	{input = " <", want = "<", type = Type.TLess},
	{input = " >", want = ">", type = Type.TGreat},
	{input = " <&", want = "<&", type = Type.TLessAnd},
	{input = " >&", want = ">&", type = Type.TGreatAnd},
	{input = " <<", want = "<<", type = Type.TDLess},
	{input = " >>", want = ">>", type = Type.TDGreat},

	-- space at the right side
	{input = "1 ", want = "1", type = Type.TIONumber},
	{input = "2 ", want = "2", type = Type.TIONumber},
	{input = "3 ", want = "3", type = Type.TIONumber},
	{input = "4 ", want = "4", type = Type.TIONumber},
	{input = "5 ", want = "5", type = Type.TIONumber},
	{input = "6 ", want = "6", type = Type.TIONumber},
	{input = "7 ", want = "7", type = Type.TIONumber},
	{input = " 8 ", want = "8", type = Type.TIONumber},
	{input = " 9 ", want = "9", type = Type.TIONumber},
	{input = "1234567890 ", want = "1234567890", type = Type.TIONumber},
	{input = "& ", want = "&", type = Type.TAnd},
	{input = "< ", want = "<", type = Type.TLess},
	{input = "> ", want = ">", type = Type.TGreat},
	{input = "<& ", want = "<&", type = Type.TLessAnd},
	{input = ">& ", want = ">&", type = Type.TGreatAnd},
	{input = "<< ", want = "<<", type = Type.TDLess},
	{input = ">> ", want = ">>", type = Type.TDGreat},

	-- space at in between
	{input = "  0  ", want = "0", type = Type.TIONumber},
	{input = "  1  ", want = "1", type = Type.TIONumber},
	{input = "  2  ", want = "2", type = Type.TIONumber},
	{input = "  3  ", want = "3", type = Type.TIONumber},
	{input = "  4  ", want = "4", type = Type.TIONumber},
	{input = "  5  ", want = "5", type = Type.TIONumber},
	{input = "  6  ", want = "6", type = Type.TIONumber},
	{input = "  7  ", want = "7", type = Type.TIONumber},
	{input = "  8  ", want = "8", type = Type.TIONumber},
	{input = "  9  ", want = "9", type = Type.TIONumber},
	{input = "  1234567890  ", want = "1234567890", type = Type.TIONumber},
	{input = "  &  ", want = "&", type = Type.TAnd},
	{input = "  <  ", want = "<", type = Type.TLess},
	{input = "  >  ", want = ">", type = Type.TGreat},
	{input = "  <&  ", want = "<&", type = Type.TLessAnd},
	{input = "  >&  ", want = ">&", type = Type.TGreatAnd},
	{input = "  <<  ", want = "<<", type = Type.TDLess},
	{input = "  >>  ", want = ">>", type = Type.TDGreat},

	{input = "", want = "", type = Type.TEOF},
	{input = "\n", want = "", type = Type.TEOF},
	{input = "\t", want = "", type = Type.TEOF},
	{input = "\n\t", want = "", type = Type.TEOF},
	{input = "\t\n", want = "", type = Type.TEOF},
	{input = "\t\n\t", want = "", type = Type.TEOF},
	{input = "\n\t\n", want = "", type = Type.TEOF},

	{input = "*", want = "*", type = Type.TUNK},
	{input = "?", want = "?", type = Type.TUNK},
	{input = "#", want = "#", type = Type.TUNK},
}

print 'lexer tests:'
for k, tt in pairs(tests) do
	lex.lex_make()
	lex.lex_readfrom(tt.input)

	local t = lex.lex_next()
	local got = ffi.string(t.text)
	
	if got ~= tt.want then
		print(string.format("\ttoken.text test at k=%d: got=%s, \z
			want=%s", k, got, tt.want))
	end

	if t.type ~= tt.type then
		print(string.format("\ttoken.type test at k=%d: got=%s, \z
			want=%s", k, t.type, tt.type))
	end
end
