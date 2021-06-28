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
	TIf = 19,
	TThen = 20,
	TElse = 21,
	TElif = 22,
	TFi = 23,
	TDo = 24,
	TDone = 25,
	TCase = 26,
	TEsac = 27,
	TWhile = 28,
	TUntil = 29,
	TFor = 30,
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
	{input = "if", want = "if", type = TokenType.TIf},
	{input = "then", want = "then", type = TokenType.TThen},
	{input = "else", want = "else", type = TokenType.TElse},
	{input = "elif", want = "elif", type = TokenType.TElif},
	{input = "fi", want = "fi", type = TokenType.TFi},
	{input = "do", want = "do", type = TokenType.TDo},
	{input = "done", want = "done", type = TokenType.TDone},
	{input = "case", want = "case", type = TokenType.TCase},
	{input = "esac", want = "esac", type = TokenType.TEsac},
	{input = "while", want = "while", type = TokenType.TWhile},
	{input = "until", want = "until", type = TokenType.TUntil},
	{input = "for", want = "for", type = TokenType.TFor},
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
	{input = " \t if \t ", want = "if", type = TokenType.TIf},
	{input = " \t then \t ", want = "then", type = TokenType.TThen},
	{input = " \t else \t ", want = "else", type = TokenType.TElse},
	{input = " \t elif \t ", want = "elif", type = TokenType.TElif},
	{input = " \t fi \t ", want = "fi", type = TokenType.TFi},
	{input = " \t do \t ", want = "do", type = TokenType.TDo},
	{input = " \t done \t ", want = "done", type = TokenType.TDone},
	{input = " \t case \t ", want = "case", type = TokenType.TCase},
	{input = " \t esac \t ", want = "esac", type = TokenType.TEsac},
	{input = " \t while \t ", want = "while", type = TokenType.TWhile},
	{input = " \t until \t ", want = "until", type = TokenType.TUntil},
	{input = " \t for \t ", want = "for", type = TokenType.TFor},
	{input = "", want = "", type = TokenType.TEOF},
	{input = " ", want = "", type = TokenType.TEOF},
	{input = "\t", want = "", type = TokenType.TEOF},
	{input = "\n", want = "", type = TokenType.TNewLine},
	{input = "ifif", want = "ifif", type = TokenType.TWord},
	{input = "thenthen", want = "thenthen", type = TokenType.TWord},
	{input = "elseelse", want = "elseelse", type = TokenType.TWord},
	{input = "elifelif", want = "elifelif", type = TokenType.TWord},
	{input = "fifi", want = "fifi", type = TokenType.TWord},
	{input = "dodo", want = "dodo", type = TokenType.TWord},
	{input = "donedone", want = "donedone", type = TokenType.TWord},
	{input = "casecase", want = "casecase", type = TokenType.TWord},
	{input = "esacesac", want = "esacesac", type = TokenType.TWord},
	{input = "whilewhile", want = "whilewhile", type = TokenType.TWord},
	{input = "untiluntil", want = "untiluntil", type = TokenType.TWord},
	{input = "forfor", want = "forfor", type = TokenType.TWord},
	{input = "ifF", want = "ifF", type = TokenType.TWord},
	{input = "thenN", want = "thenN", type = TokenType.TWord},
	{input = "elseE", want = "elseE", type = TokenType.TWord},
	{input = "elifF", want = "elifF", type = TokenType.TWord},
	{input = "fiI", want = "fiI", type = TokenType.TWord},
	{input = "doO", want = "doO", type = TokenType.TWord},
	{input = "doneE", want = "doneE", type = TokenType.TWord},
	{input = "caseE", want = "caseE", type = TokenType.TWord},
	{input = "esacC", want = "esacC", type = TokenType.TWord},
	{input = "whileE", want = "whileE", type = TokenType.TWord},
	{input = "untilL", want = "untilL", type = TokenType.TWord},
	{input = "forR", want = "forR", type = TokenType.TWord},
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
	{
		input = "if 78 then h23 else elif fi do done case esac while until for",
		tokens = {
			{type = TokenType.TIf, text = "if"},
			{type = TokenType.TWord, text = "78"},
			{type = TokenType.TThen, text = "then"},
			{type = TokenType.TWord, text = "h23"},
			{type = TokenType.TElse, text = "else"},
			{type = TokenType.TElif, text = "elif"},
			{type = TokenType.TFi, text = "fi"},
			{type = TokenType.TDo, text = "do"},
			{type = TokenType.TDone, text = "done"},
			{type = TokenType.TCase, text = "case"},
			{type = TokenType.TEsac, text = "esac"},
			{type = TokenType.TWhile, text = "while"},
			{type = TokenType.TUntil, text = "until"},
			{type = TokenType.TFor, text = "for"},
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
