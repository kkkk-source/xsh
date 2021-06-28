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
    TIf,        // if
    TThen,      // then
    TElse,      // else
    TElif,      // elif
    TFi,        // fi
    TDo,        // do
    TDone,      // done
    TCase,      // case
    TEsac,      // esac
    TWhile,     // while
    TUntil,     // until
    TFor,       // for
} TokenType;

typedef struct __sToken {
    char * text;
    TokenType   type;
} Token;

Lex * lex_make(void);
void lex_readfrom(const char *);
Token *lex_next(void);

]]

TokenType = {
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
	{input = "0", want = "0", type = TokenType.TWord},
	{input = "1", want = "1", type = TokenType.TWord},
	{input = "2", want = "2", type = TokenType.TWord},
	{input = "3", want = "3", type = TokenType.TWord},
	{input = "4", want = "4", type = TokenType.TWord},
	{input = "5", want = "5", type = TokenType.TWord},
	{input = "6", want = "6", type = TokenType.TWord},
	{input = "7", want = "7", type = TokenType.TWord},
	{input = "8", want = "8", type = TokenType.TWord},
	{input = "9", want = "9", type = TokenType.TWord},
	{input = "1234567890", want = "1234567890", type = TokenType.TWord},
	{input = "&", want = "&", type = TokenType.TAnd},
	{input = "|", want = "|", type = TokenType.TOr},
	{input = ";", want = ";", type = TokenType.TSemi},
	{input = "<", want = "<", type = TokenType.TLess},
	{input = ">", want = ">", type = TokenType.TGreat},
	{input = "&&", want = "&&", type = TokenType.TAndIf},
	{input = "||", want = "||", type = TokenType.TOrIf},
	{input = ";;", want = ";;", type = TokenType.TDSemi},
	{input = "<<", want = "<<", type = TokenType.TDLess},
	{input = ">>", want = ">>", type = TokenType.TDGreat},
	{input = "<&", want = "<&", type = TokenType.TLessAnd},
	{input = ">&", want = ">&", type = TokenType.TGreatAnd},
	{input = "<>", want = "<>", type = TokenType.TLessGreat},
	{input = "<<-", want = "<<-", type = TokenType.TDLessDash},
	{input = ">|", want = ">|", type = TokenType.TLobber},
	{input = " \t 0 \t ", want = "0", type = TokenType.TWord},
	{input = " \t 1 \t ", want = "1", type = TokenType.TWord},
	{input = " \t 2 \t ", want = "2", type = TokenType.TWord},
	{input = " \t 3 \t ", want = "3", type = TokenType.TWord},
	{input = " \t 4 \t ", want = "4", type = TokenType.TWord},
	{input = " \t 5 \t ", want = "5", type = TokenType.TWord},
	{input = " \t 6 \t ", want = "6", type = TokenType.TWord},
	{input = " \t 7 \t ", want = "7", type = TokenType.TWord},
	{input = " \t 8 \t ", want = "8", type = TokenType.TWord},
	{input = " \t 9 \t ", want = "9", type = TokenType.TWord},
	{input = " \t 1234567890 \t ", want = "1234567890", type = TokenType.TWord},
	{input = " \t & \t ", want = "&", type = TokenType.TAnd},
	{input = " \t | \t", want = "|", type = TokenType.TOr},
	{input = " \t ; \t ", want = ";", type = TokenType.TSemi},
	{input = " \t < \t ", want = "<", type = TokenType.TLess},
	{input = " \t > \t ", want = ">", type = TokenType.TGreat},
	{input = " \t && \t ", want = "&&", type = TokenType.TAndIf},
	{input = " \t || \t ", want = "||", type = TokenType.TOrIf},
	{input = " \t ;; \t ", want = ";;", type = TokenType.TDSemi},
	{input = " \t & \t ", want = "&", type = TokenType.TAnd},
	{input = " \t << \t ", want = "<<", type = TokenType.TDLess},
	{input = " \t >> \t ", want = ">>", type = TokenType.TDGreat},
	{input = " \t <& \t ", want = "<&", type = TokenType.TLessAnd},
	{input = " \t >& \t ", want = ">&", type = TokenType.TGreatAnd},
	{input = " \t <> \t ", want = "<>", type = TokenType.TLessGreat},
	{input = " \t <<- \t ", want = "<<-", type = TokenType.TDLessDash},
	{input = " \t >| \t ", want = ">|", type = TokenType.TLobber},
	{input = "", want = "", type = TokenType.TEOF},
	{input = " ", want = "", type = TokenType.TEOF},
	{input = "\t", want = "", type = TokenType.TEOF},
	{input = "\n", want = "", type = TokenType.TNewLine},
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
			{type = TokenType.TWord, text = "0"},
			{type = TokenType.TWord, text = "1"},
			{type = TokenType.TWord, text = "2"},
			{type = TokenType.TWord, text = "3"},
			{type = TokenType.TWord, text = "4"},
		},
	},
	{
		input = "><|&;",
		tokens = {
			{type = TokenType.TGreat, text = ">"},
			{type = TokenType.TLess, text = "<"},
			{type = TokenType.TOr, text = "|"},
			{type = TokenType.TAnd, text = "&"},
			{type = TokenType.TSemi, text = ";"},
		},
	},
	{
		input = "&&||;;",
		tokens = {
			{type = TokenType.TAndIf, text = "&&"},
			{type = TokenType.TOrIf, text = "||"},
			{type = TokenType.TDSemi, text = ";;"},
		},
	},
	{
		input = "<<<<&<&<<<><<-<",
		tokens = {
			{type = TokenType.TDLess, text = "<<"},
			{type = TokenType.TDLess, text = "<<"},
			{type = TokenType.TAnd, text = "&"},
			{type = TokenType.TLessAnd, text = "<&"},
			{type = TokenType.TDLess, text = "<<"},
			{type = TokenType.TLessGreat, text = "<>"},
			{type = TokenType.TDLessDash, text = "<<-"},
			{type = TokenType.TLess, text = "<"},
		},
	},
	{
		input = ">>>>&>&>>>|",
		tokens = {
			{type = TokenType.TDGreat, text = ">>"},
			{type = TokenType.TDGreat, text = ">>"},
			{type = TokenType.TAnd, text = "&"},
			{type = TokenType.TGreatAnd, text = ">&"},
			{type = TokenType.TDGreat, text = ">>"},
			{type = TokenType.TLobber, text = ">|"},
		},
	},
	{
		input = "1<&2",
		tokens = {
			{type = TokenType.TIONumber, text = "1"},
			{type = TokenType.TLessAnd, text = "<&"},
			{type = TokenType.TIONumber, text = "2"},
		},
	},
	{
		input = "1&2",
		tokens = {
			{type = TokenType.TWord, text = "1"},
			{type = TokenType.TAnd, text = "&"},
			{type = TokenType.TWord, text = "2"},
		},
	},
	{
		input = "12345678901234567890<&12345678901234567890",
		tokens = {
			{type = TokenType.TIONumber, text = "12345678901234567890"},
			{type = TokenType.TLessAnd, text = "<&"},
			{type = TokenType.TIONumber, text = "12345678901234567890"},
		},
	},
	{
		input = "12345678901234567890&12345678901234567890",
		tokens = {
			{type = TokenType.TWord, text = "12345678901234567890"},
			{type = TokenType.TAnd, text = "&"},
			{type = TokenType.TWord, text = "12345678901234567890"},
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
