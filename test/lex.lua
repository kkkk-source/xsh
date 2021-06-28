local ffi = require('ffi')
local lex = ffi.load('test/lex.so')

ffi.cdef [[

typedef struct __sFILE FILE;
typedef struct __sLex Lex;

typedef enum {
    TEOF,       // End of file
    TWord,      // any
    TIONumber,  // Integer positive number delimited by '<' or '>'
    TNewLine,   // \n
    TAnd,       // &
    TOr,        // |
    TSemi,      // ;
    TAndIf,     // &&
    TOrIf,      // ||
    TDSemi,     // ;;
    TLess,      // <
    TGreat,     // >
    TDLess,     // <<
    TDGreat,    // >>
    TLessAnd,   // <&
    TGreatAnd,  // >&
    TLessGreat, // <>
    TDLessDash, // <<-
    TLobber,    // >|
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
	TWord = 1,
	TIONumber = 2,
	TNewLine = 3,
	TAnd = 4,
	TOr = 5,
	TSemi = 6,
	TAndIf = 7,
	TOrIf = 8,
	TDSemi = 9,
	TLess = 10,
	TGreat = 11,
	TDLess = 12,
	TDGreat = 13,
	TLessAnd = 14,
	TGreatAnd = 15,
	TLessGreat = 16,
	TDLessDash = 17,
	TLobber = 18,
}

local stests = {
	{input = "0", want = "0", type = Type.TWord},
	{input = "1", want = "1", type = Type.TWord},
	{input = "2", want = "2", type = Type.TWord},
	{input = "3", want = "3", type = Type.TWord},
	{input = "4", want = "4", type = Type.TWord},
	{input = "5", want = "5", type = Type.TWord},
	{input = "6", want = "6", type = Type.TWord},
	{input = "7", want = "7", type = Type.TWord},
	{input = "8", want = "8", type = Type.TWord},
	{input = "9", want = "9", type = Type.TWord},
	{input = "1234567890", want = "1234567890", type = Type.TWord},
	{input = "&", want = "&", type = Type.TAnd},
	{input = "|", want = "|", type = Type.TOr},
	{input = ";", want = ";", type = Type.TSemi},
	{input = "<", want = "<", type = Type.TLess},
	{input = ">", want = ">", type = Type.TGreat},
	{input = "&&", want = "&&", type = Type.TAndIf},
	{input = "||", want = "||", type = Type.TOrIf},
	{input = ";;", want = ";;", type = Type.TDSemi},
	{input = "<<", want = "<<", type = Type.TDLess},
	{input = ">>", want = ">>", type = Type.TDGreat},
	{input = "<&", want = "<&", type = Type.TLessAnd},
	{input = ">&", want = ">&", type = Type.TGreatAnd},
	{input = "<>", want = "<>", type = Type.TLessGreat},
	{input = "<<-", want = "<<-", type = Type.TDLessDash},
	{input = ">|", want = ">|", type = Type.TLobber},
	{input = " \t 0 \t ", want = "0", type = Type.TWord},
	{input = " \t 1 \t ", want = "1", type = Type.TWord},
	{input = " \t 2 \t ", want = "2", type = Type.TWord},
	{input = " \t 3 \t ", want = "3", type = Type.TWord},
	{input = " \t 4 \t ", want = "4", type = Type.TWord},
	{input = " \t 5 \t ", want = "5", type = Type.TWord},
	{input = " \t 6 \t ", want = "6", type = Type.TWord},
	{input = " \t 7 \t ", want = "7", type = Type.TWord},
	{input = " \t 8 \t ", want = "8", type = Type.TWord},
	{input = " \t 9 \t ", want = "9", type = Type.TWord},
	{input = " \t 1234567890 \t ", want = "1234567890", type = Type.TWord},
	{input = " \t & \t ", want = "&", type = Type.TAnd},
	{input = " \t | \t", want = "|", type = Type.TOr},
	{input = " \t ; \t ", want = ";", type = Type.TSemi},
	{input = " \t < \t ", want = "<", type = Type.TLess},
	{input = " \t > \t ", want = ">", type = Type.TGreat},
	{input = " \t && \t ", want = "&&", type = Type.TAndIf},
	{input = " \t || \t ", want = "||", type = Type.TOrIf},
	{input = " \t ;; \t ", want = ";;", type = Type.TDSemi},
	{input = " \t & \t ", want = "&", type = Type.TAnd},
	{input = " \t << \t ", want = "<<", type = Type.TDLess},
	{input = " \t >> \t ", want = ">>", type = Type.TDGreat},
	{input = " \t <& \t ", want = "<&", type = Type.TLessAnd},
	{input = " \t >& \t ", want = ">&", type = Type.TGreatAnd},
	{input = " \t <> \t ", want = "<>", type = Type.TLessGreat},
	{input = " \t <<- \t ", want = "<<-", type = Type.TDLessDash},
	{input = " \t >| \t ", want = ">|", type = Type.TLobber},
	{input = "", want = "", type = Type.TEOF},
	{input = " ", want = "", type = Type.TEOF},
	{input = "\t", want = "", type = Type.TEOF},
	{input = "\n", want = "", type = Type.TNewLine},
}

print '\tlexer test: single tokens'
lex.lex_make()
for k, tt in pairs(stests) do
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
		input = " 0 1 2 3 4 ",
		tokens = {
			{type = Type.TWord, text = "0"},
			{type = Type.TWord, text = "1"},
			{type = Type.TWord, text = "2"},
			{type = Type.TWord, text = "3"},
			{type = Type.TWord, text = "4"},
		},
	},
	{
		input = "><|&;",
		tokens = {
			{type = Type.TGreat, text = ">"},
			{type = Type.TLess, text = "<"},
			{type = Type.TOr, text = "|"},
			{type = Type.TAnd, text = "&"},
			{type = Type.TSemi, text = ";"},
		},
	},
	{
		input = "&&||;;",
		tokens = {
			{type = Type.TAndIf, text = "&&"},
			{type = Type.TOrIf, text = "||"},
			{type = Type.TDSemi, text = ";;"},
		},
	},
	{
		input = "<<<<&<&<<<><<-<",
		tokens = {
			{type = Type.TDLess, text = "<<"},
			{type = Type.TDLess, text = "<<"},
			{type = Type.TAnd, text = "&"},
			{type = Type.TLessAnd, text = "<&"},
			{type = Type.TDLess, text = "<<"},
			{type = Type.TLessGreat, text = "<>"},
			{type = Type.TDLessDash, text = "<<-"},
			{type = Type.TLess, text = "<"},
		},
	},
	{
		input = ">>>>&>&>>>|",
		tokens = {
			{type = Type.TDGreat, text = ">>"},
			{type = Type.TDGreat, text = ">>"},
			{type = Type.TAnd, text = "&"},
			{type = Type.TGreatAnd, text = ">&"},
			{type = Type.TDGreat, text = ">>"},
			{type = Type.TLobber, text = ">|"},
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
		input = "1&2",
		tokens = {
			{type = Type.TWord, text = "1"},
			{type = Type.TAnd, text = "&"},
			{type = Type.TWord, text = "2"},
		},
	},
	{
		input = "12345678901234567890<&12345678901234567890",
		tokens = {
			{type = Type.TIONumber, text = "12345678901234567890"},
			{type = Type.TLessAnd, text = "<&"},
			{type = Type.TIONumber, text = "12345678901234567890"},
		},
	},
	{
		input = "12345678901234567890&12345678901234567890",
		tokens = {
			{type = Type.TWord, text = "12345678901234567890"},
			{type = Type.TAnd, text = "&"},
			{type = Type.TWord, text = "12345678901234567890"},
		},
	},
}

print '\tlexer test: multiple tokens'
lex.lex_make()
for k, tt in pairs(mtests) do
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
