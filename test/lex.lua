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

local stests = {
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
	{input = " ", want = "", type = Type.TEOF},
	{input = "\n", want = "", type = Type.TEOF},
	{input = "\t", want = "", type = Type.TEOF},

	{input = "*", want = "*", type = Type.TUNK},
	{input = "?", want = "?", type = Type.TUNK},
	{input = "#", want = "#", type = Type.TUNK},
}

print 'lexer tests: single tokens'
for k, tt in pairs(stests) do
	lex.lex_make()
	lex.lex_readfrom(tt.input)

	local t = lex.lex_next()
	
	if t.type ~= tt.type then
		print(string.format("\ttoken.type test at k=%d: got=%s, \z
			want=%s", k, t.type, tt.type))
	end

	if ffi.string(t.text) ~= tt.want then
		print(string.format("\ttoken.text test at k=%d: got=%s, \z
			want=%s", k, ffi.string(t.text), tt.want))
	end
end


local mtests = {
	{
		input = " 0 1 2 3 4 5 6 7 8 9 ",
		tokens = {
			{type = Type.TIONumber, text = "0"},
			{type = Type.TIONumber, text = "1"},
			{type = Type.TIONumber, text = "2"},
			{type = Type.TIONumber, text = "3"},
			{type = Type.TIONumber, text = "4"},
			{type = Type.TIONumber, text = "5"},
			{type = Type.TIONumber, text = "6"},
			{type = Type.TIONumber, text = "7"},
			{type = Type.TIONumber, text = "8"},
			{type = Type.TIONumber, text = "9"},
		},
	},
	{
		input = "&<&<<",
		tokens = {
			{type = Type.TAnd, text = "&"},
			{type = Type.TLessAnd, text = "<&"},
			{type = Type.TDLess, text = "<<"},
		},
	},
	{
		input = "&>&>>",
		tokens = {
			{type = Type.TAnd, text = "&"},
			{type = Type.TGreatAnd, text = ">&"},
			{type = Type.TDGreat, text = ">>"},
		},
	},
	{
		input = "1<&2",
		tokens = {
			{type = Type.TIONumber, text = "1"},
			{type = Type.TLessAnd, text = "<&"},
			{type = Type.TIONumber, text = "2"},
		},
	},
	{
		input = "1>&2",
		tokens = {
			{type = Type.TIONumber, text = "1"},
			{type = Type.TGreatAnd, text = ">&"},
			{type = Type.TIONumber, text = "2"},
		},
	},
	{
		input = "1>>2",
		tokens = {
			{type = Type.TIONumber, text = "1"},
			{type = Type.TDGreat, text = ">>"},
			{type = Type.TIONumber, text = "2"},
		},
	},
	{
		input = "1<<2",
		tokens = {
			{type = Type.TIONumber, text = "1"},
			{type = Type.TDLess, text = "<<"},
			{type = Type.TIONumber, text = "2"},
		},
	},
	{
		input = "012345678901234567890&0123456878901234567890",
		tokens = {
			{type = Type.TIONumber, text = "012345678901234567890"},
			{type = Type.TAnd, text = "&"},
			{type = Type.TIONumber, text = "0123456878901234567890"},
		},
	},
}

print 'lexer tests: multiple tokens'
for k, tt in pairs(mtests) do
	lex.lex_make()
	lex.lex_readfrom(tt.input)

	for _, want in pairs(tt.tokens) do
		local got = lex.lex_next()

		if got.type ~= want.type then
			print(string.format("\ttoken.type test at k=%d: got=%s, \z
				want=%s", k, got.type, want.type))
		end

		if ffi.string(got.text) ~= want.text then
			print(string.format("\ttoken.text test at k=%d: got=%s, \z
				want=%s", k, ffi.string(got.text), want.text))
		end
	end
end
