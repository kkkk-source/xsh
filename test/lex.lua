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

local tests = {
	{input = "0", tokens = {{type = TokenType.TWord, text = "0"}}},
	{input = "&", tokens = {{type = TokenType.TAnd, text = "&"}}},
	{input = "|", tokens = {{type = TokenType.TOr, text = "|"}}},
	{input = ";", tokens = {{type = TokenType.TSemi, text = ";"}}},
	{input = "<", tokens = {{type = TokenType.TLess, text = "<"}}},
	{input = ">", tokens = {{type = TokenType.TGreat, text = ">"}}},
	{input = "&&", tokens = {{type = TokenType.TAndIf, text = "&&"}}},
	{input = "||", tokens = {{type = TokenType.TOrIf, text = "||"}}},
	{input = ";;", tokens = {{type = TokenType.TDSemi, text = ";;"}}},
	{input = "<<", tokens = {{type = TokenType.TDLess, text = "<<"}}},
	{input = ">>", tokens = {{type = TokenType.TDGreat, text = ">>"}}},
	{input = "<&", tokens = {{type = TokenType.TLessAnd, text = "<&"}}},
	{input = ">&", tokens = {{type = TokenType.TGreatAnd, text = ">&"}}},
	{input = "<>", tokens = {{type = TokenType.TLessGreat, text = "<>"}}},
	{input = "<<-", tokens = {{type = TokenType.TDLessDash, text = "<<-"}}},
	{input = ">|", tokens = {{type = TokenType.TLobber, text = ">|"}}},
	{input = "if", tokens = {{type = TokenType.TIf, text = "if"}}},
	{input = "then", tokens = {{type = TokenType.TThen, text = "then"}}},
	{input = "else", tokens = {{type = TokenType.TElse, text = "else"}}},
	{input = "elif", tokens = {{type = TokenType.TElif, text = "elif"}}},
	{input = "fi", tokens = {{type = TokenType.TFi, text = "fi"}}},
	{input = "do", tokens = {{type = TokenType.TDo, text = "do"}}},
	{input = "done", tokens = {{type = TokenType.TDone, text = "done"}}},
	{input = "case", tokens = {{type = TokenType.TCase, text = "case"}}},
	{input = "esac", tokens = {{type = TokenType.TEsac, text = "esac"}}},
	{input = "while", tokens = {{type = TokenType.TWhile, text = "while"}}},
	{input = "until", tokens = {{type = TokenType.TUntil, text = "until"}}},
	{input = "ift", tokens = {{type = TokenType.TWord, text = "ift"}}},
	{input = "thent", tokens = {{type = TokenType.TWord, text = "thent"}}},
	{input = "elset", tokens = {{type = TokenType.TWord, text = "elset"}}},
	{input = "elift", tokens = {{type = TokenType.TWord, text = "elift"}}},
	{input = "fit", tokens = {{type = TokenType.TWord, text = "fit"}}},
	{input = "tdot", tokens = {{type = TokenType.TWord, text = "tdot"}}},
	{input = "tdone", tokens = {{type = TokenType.TWord, text = "tdone"}}},
	{input = "tcase", tokens = {{type = TokenType.TWord, text = "tcase"}}},
	{input = "tesac", tokens = {{type = TokenType.TWord, text = "tesac"}}},
	{input = "twhile", tokens = {{type = TokenType.TWord, text = "twhile"}}},
	{input = "tuntil", tokens = {{type = TokenType.TWord, text = "tuntil"}}},
	{input = "&&||;;<<>>&>&<><<->|", tokens = {
		{type = TokenType.TAndIf, text = "&&"},
		{type = TokenType.TOrIf, text = "||"},
		{type = TokenType.TDSemi, text = ";;"},
		{type = TokenType.TDLess, text = "<<"},
		{type = TokenType.TDGreat, text = ">>"},
		{type = TokenType.TAnd, text = "&"},
		{type = TokenType.TGreatAnd, text = ">&"},
		{type = TokenType.TLessGreat, text = "<>"},
		{type = TokenType.TDLessDash, text = "<<-"},
		{type = TokenType.TLobber, text = ">|"}}
	},
	{input = "0&a", tokens = {
		{type = TokenType.TWord, text = "0"},
		{type = TokenType.TAnd, text = "&"},
		{type = TokenType.TWord, text = "a"}}
	},
	{input = "1|b", tokens = {
		{type = TokenType.TWord, text = "1"},
		{type = TokenType.TOr, text = "|"},
		{type = TokenType.TWord, text = "b"}}
	},
	{input = "2;c", tokens = {
		{type = TokenType.TWord, text = "2"},
		{type = TokenType.TSemi, text = ";"},
		{type = TokenType.TWord, text = "c"}}
	},
	{input = "3&&&d", tokens = {
		{type = TokenType.TWord, text = "3"},
		{type = TokenType.TAndIf, text = "&&"},
		{type = TokenType.TAnd, text = "&"},
		{type = TokenType.TWord, text = "d"}}
	},
	{input = "4|||e", tokens = {
		{type = TokenType.TWord, text = "4"},
		{type = TokenType.TOrIf, text = "||"},
		{type = TokenType.TOr, text = "|"},
		{type = TokenType.TWord, text = "e"}}
	},
	{input = "5;;;f", tokens = {
		{type = TokenType.TWord, text = "5"},
		{type = TokenType.TDSemi, text = ";;"},
		{type = TokenType.TSemi, text = ";"},
		{type = TokenType.TWord, text = "f"}}
	},
	{input = "&&&&", tokens = {
		{type = TokenType.TAndIf, text = "&&"},
		{type = TokenType.TAndIf, text = "&&"}}
	},
	{input = "||||", tokens = {
		{type = TokenType.TOrIf, text = "||"},
		{type = TokenType.TOrIf, text = "||"}}
	},
	{input = ";;;;", tokens = {
		{type = TokenType.TDSemi, text = ";;"},
		{type = TokenType.TDSemi, text = ";;"}}
	},
	{input = ">>>", tokens = {
		{type = TokenType.TDGreat, text = ">>"},
		{type = TokenType.TGreat, text = ">"}}
	},
	{input = "<<<", tokens = {
		{type = TokenType.TDLess, text = "<<"},
		{type = TokenType.TLess, text = "<"}}
	},
	{input = "<<<<", tokens = {
		{type = TokenType.TDLess, text = "<<"},
		{type = TokenType.TDLess, text = "<<"}}
	},
	{input = ">>>>", tokens = {
		{type = TokenType.TDGreat, text = ">>"},
		{type = TokenType.TDGreat, text = ">>"}}
	},
	{input = "<&<&", tokens = {
		{type = TokenType.TLessAnd, text = "<&"},
		{type = TokenType.TLessAnd, text = "<&"}}
	},
	{input = ">&>&", tokens = {
		{type = TokenType.TGreatAnd, text = ">&"},
		{type = TokenType.TGreatAnd, text = ">&"}}
	},
	{input = "<<-<<-", tokens = {
		{type = TokenType.TDLessDash, text = "<<-"},
		{type = TokenType.TDLessDash, text = "<<-"}}
	},
	{input = ">|>|", tokens = {
		{type = TokenType.TLobber, text = ">|"},
		{type = TokenType.TLobber, text = ">|"}}
	},
	{input = "0<1", tokens = {
		{type = TokenType.TIONumber, text = "0"},
		{type = TokenType.TLess, text = "<"},
		{type = TokenType.TWord, text = "1"}}
	},
	{input = "2>3", tokens = {
		{type = TokenType.TIONumber, text = "2"},
		{type = TokenType.TGreat, text = ">"},
		{type = TokenType.TWord, text = "3"}}
	},
	{input = "4<&5", tokens = {
		{type = TokenType.TIONumber, text = "4"},
		{type = TokenType.TLessAnd, text = "<&"},
		{type = TokenType.TWord, text = "5"}}
	},
	{input = "6>&7", tokens = {
		{type = TokenType.TIONumber, text = "6"},
		{type = TokenType.TGreatAnd, text = ">&"},
		{type = TokenType.TWord, text = "7"}}
	},
	{input = "8>|9", tokens = {
		{type = TokenType.TIONumber, text = "8"},
		{type = TokenType.TLobber, text = ">|"},
		{type = TokenType.TWord, text = "9"}}
	},
	{input = "10>>11", tokens = {
		{type = TokenType.TIONumber, text = "10"},
		{type = TokenType.TDGreat, text = ">>"},
		{type = TokenType.TWord, text = "11"}}
	},
	{input = "12<<13", tokens = {
		{type = TokenType.TIONumber, text = "12"},
		{type = TokenType.TDLess, text = "<<"},
		{type = TokenType.TWord, text = "13"}}
	},
	{input = "14<>15", tokens = {
		{type = TokenType.TIONumber, text = "14"},
		{type = TokenType.TLessGreat, text = "<>"},
		{type = TokenType.TWord, text = "15"}}
	},
	{
		input = "0 & | ; < > && || ;; << >> <& >& <> <<- >|",
		tokens = {
			{type = TokenType.TWord, text = "0"},
			{type = TokenType.TAnd, text = "&"},
			{type = TokenType.TOr, text = "|"},
			{type = TokenType.TSemi, text = ";"},
			{type = TokenType.TLess, text = "<"},
			{type = TokenType.TGreat, text = ">"},
			{type = TokenType.TAndIf, text = "&&"},
			{type = TokenType.TOrIf, text = "||"},
			{type = TokenType.TDSemi, text = ";;"},
			{type = TokenType.TDLess, text = "<<"},
			{type = TokenType.TDGreat, text = ">>"},
			{type = TokenType.TLessAnd, text = "<&"},
			{type = TokenType.TGreatAnd, text = ">&"},
			{type = TokenType.TLessGreat, text = "<>"},
			{type = TokenType.TDLessDash, text = "<<-"},
			{type = TokenType.TLobber, text = ">|"},
		},
	},
	{
		input = "if then else elif fi do done case esac while until",
		tokens = {
			{type = TokenType.TIf, text = "if"},
			{type = TokenType.TThen, text = "then"},
			{type = TokenType.TElse, text = "else"},
			{type = TokenType.TElif, text = "elif"},
			{type = TokenType.TFi, text = "fi"},
			{type = TokenType.TDo, text = "do"},
			{type = TokenType.TDone, text = "done"},
			{type = TokenType.TCase, text = "case"},
			{type = TokenType.TEsac, text = "esac"},
			{type = TokenType.TWhile, text = "while"},
			{type = TokenType.TUntil, text = "until"},
		},
	},
}

print '\tlexer test:'
lex.lex_make()
for k, tt in pairs(tests) do
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
