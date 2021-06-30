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
    TLBrace,    // {
    TRBrace,    // }
    TBang,      // !
    TIn,        // in
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
	TLBrace = 31,
	TRBrace = 32,
	TBang = 33,
	TIn = 34,
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
	{input = "until", tokens = {{type = TokenType.TUntil, text = "until"}}},
	{input = "while", tokens = {{type = TokenType.TWhile, text = "while"}}},
	{input = "{", tokens = {{type = TokenType.TLBrace, text = "{"}}},
	{input = "}", tokens = {{type = TokenType.TRBrace, text = "}"}}},
	{input = "!", tokens = {{type = TokenType.TBang, text = "!"}}},
	{input = "in", tokens = {{type = TokenType.TWord, text = "in"}}},
	{
		input = [[
		for word in word word word
		do
			word
			word
		done

		case word in
			;;
			;;
		esac

		while word in
		do
			word
			word
		done

		until word in
		do
			word
			word
		done

		if word in
		then
			word
			word
		elif
			word
			word
		else
			word
			word
		fi
		]], 
		tokens = {
			{type = TokenType.TFor, text = "for"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TIn, text = "in"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TDo, text = "do"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TDone, text = "done"},
			{type = TokenType.TCase, text = "case"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TIn, text = "in"},
			{type = TokenType.TDSemi, text = ";;"},
			{type = TokenType.TDSemi, text = ";;"},
			{type = TokenType.TEsac, text = "esac"},
			{type = TokenType.TWhile, text = "while"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "in"},
			{type = TokenType.TDo, text = "do"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TDone, text = "done"},
			{type = TokenType.TUntil, text = "until"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "in"},
			{type = TokenType.TDo, text = "do"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TDone, text = "done"},
			{type = TokenType.TIf, text = "if"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "in"},
			{type = TokenType.TThen, text = "then"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TElif, text = "elif"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TElse, text = "else"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TFi, text = "fi"},
		}},
	{
		input = [[
		word word<word
		word word>word
		word word<<word
		word word>>word
		word word<&word
		word word>&word
		word word<>word
		word word<<-word
		word word>|word
		word 1<2
		word 1>2
		word 1<<2
		word 1>>2
		word 1<&2
		word 1>&2
		word 1<>2
		word 1<<-2
		word 1>|2
		]],
		tokens = {
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TLess, text = "<"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TGreat, text = ">"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TDLess, text = "<<"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TDGreat, text = ">>"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TLessAnd, text = "<&"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TGreatAnd, text = ">&"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TLessGreat, text = "<>"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TDLessDash, text = "<<-"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TLobber, text = ">|"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TIONumber, text = "1"},
			{type = TokenType.TLess, text = "<"},
			{type = TokenType.TWord, text = "2"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TIONumber, text = "1"},
			{type = TokenType.TGreat, text = ">"},
			{type = TokenType.TWord, text = "2"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TIONumber, text = "1"},
			{type = TokenType.TDLess, text = "<<"},
			{type = TokenType.TWord, text = "2"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TIONumber, text = "1"},
			{type = TokenType.TDGreat, text = ">>"},
			{type = TokenType.TWord, text = "2"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TIONumber, text = "1"},
			{type = TokenType.TLessAnd, text = "<&"},
			{type = TokenType.TWord, text = "2"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TIONumber, text = "1"},
			{type = TokenType.TGreatAnd, text = ">&"},
			{type = TokenType.TWord, text = "2"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TIONumber, text = "1"},
			{type = TokenType.TLessGreat, text = "<>"},
			{type = TokenType.TWord, text = "2"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TIONumber, text = "1"},
			{type = TokenType.TDLessDash, text = "<<-"},
			{type = TokenType.TWord, text = "2"},
			{type = TokenType.TWord, text = "word"},
			{type = TokenType.TIONumber, text = "1"},
			{type = TokenType.TLobber, text = ">|"},
			{type = TokenType.TWord, text = "2"},
		}
	},
	{
		input = [[
		&&&& 
		|||| 
		;;;; 
		<<<< 
		>>>> 
		<&<&
		>&>&
		<<-<<-
		>|>|
		<><>
		]],
		tokens = {
			{type = TokenType.TAndIf, text = "&&"},
			{type = TokenType.TAndIf, text = "&&"},
			{type = TokenType.TOrIf, text = "||"},
			{type = TokenType.TOrIf, text = "||"},
			{type = TokenType.TDSemi, text = ";;"},
			{type = TokenType.TDSemi, text = ";;"},
			{type = TokenType.TDLess, text = "<<"},
			{type = TokenType.TDLess, text = "<<"},
			{type = TokenType.TDGreat, text = ">>"},
			{type = TokenType.TDGreat, text = ">>"},
			{type = TokenType.TLessAnd, text = "<&"},
			{type = TokenType.TLessAnd, text = "<&"},
			{type = TokenType.TGreatAnd, text = ">&"},
			{type = TokenType.TGreatAnd, text = ">&"},
			{type = TokenType.TDLessDash, text = "<<-"},
			{type = TokenType.TDLessDash, text = "<<-"},
			{type = TokenType.TLobber, text = ">|"},
			{type = TokenType.TLobber, text = ">|"},
			{type = TokenType.TLessGreat, text = "<>"},
			{type = TokenType.TLessGreat, text = "<>"},
		}
	}
}

print '\tlexer test:'
lex.lex_make()
for k, tt in pairs(tests) do
	lex.lex_readfrom(tt.input)

	for _, want in pairs(tt.tokens) do
		local got = lex.lex_next()

		if got.type ~= want.type or ffi.string(got.text) ~= want.text then
			print(string.format("\ttoken.text test at k=%d: got=%s, \z
				want=%s", k, ffi.string(got.text), want.text))
			print(string.format("\ttoken.type test at k=%d: got=%s, \z
				want=%s", k, got.type, want.type))
		end
	end
end
