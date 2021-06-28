local ffi = require('ffi')
local keyw = ffi.load('test/keyw.so')

ffi.cdef [[

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

TokenType keyw_gettype(const char *);

]]

TokenType = {
	TWord = 1,
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
	{keyword = "if", want = TokenType.TIf},
	{keyword = "then", want = TokenType.TThen},
	{keyword = "else", want = TokenType.TElse},
	{keyword = "elif", want = TokenType.TElif},
	{keyword = "fi", want = TokenType.TFi},
	{keyword = "do", want = TokenType.TDo},
	{keyword = "done", want = TokenType.TDone},
	{keyword = "case", want = TokenType.TCase},
	{keyword = "esac", want = TokenType.TEsac},
	{keyword = "while", want = TokenType.TWhile},
	{keyword = "until", want = TokenType.TUntil},
	{keyword = "for", want = TokenType.TFor},
	{keyword = "ifforuntil", want = TokenType.TWord},
}

print '\tkeyw test: keywords'
for k, t in pairs(tests) do
	local got = keyw.keyw_gettype(t.keyword)

	if got ~= t.want then
		print(string.format("\tkeyword.type test at k=%d: got=%s, \z
			want=%s", k, got, t.want))
	end
end
