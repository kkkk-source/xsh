//
// lex.h - lexical analysis
//

#include <stdio.h>
#include <stdbool.h>

typedef enum {
    TEOF,			// End of file
    TWord,			// Any
    TIONumber,			// Integer positive number delimited by '<' or '>'
    TNewLine,			// \n
    TAndIf,			// &&
    TOrIf,			// ||
    TDSemi,			// ;;
    TAnd,			// &
    TLess,			// <
    TGreat,			// >
    TDLess,			// <<
    TDGreat,			// >>
    TLessAnd,			// <&
    TGreatAnd,			// >&
    TLessGreat,			// <>
    TDLessDash,			// <<-
    TLobber,			// >|
} Type;

// Lex holds the state of the lexer.
typedef struct __sLex {

    // input is the read-only current line under examination.
    const char *input;

    // Lex->input = [ x | x | x | x | x | x | x | \0 ]
    //                                    ^
    //                                    |
    //                                   pos
    //
    // pos is the position in the input of the current character under
    // examination.
    int pos;

    // Lex->input = [ x | x | x | x | x | x | x | \0 ]
    //                    ^           ^
    //                    |           |
    //                   stt         pos
    //
    // stt is the start position of the substring under examination. This
    // substring is supposed to be the text value of the field of a token. 
    int stt;

    // done is set to true if there is no more characters in the input to
    // read from. It is just set to false when lex_readfrom() get called.
    bool done;

    // When there is a sequence of characteres of the form "1<&2", where '1'
    // and '2' can be any number, then, '1' and '2' are tokens of the type
    // TIONumber (IO_NUMBER). Therefore, when Lex->del is set to true, it
    // lets "2" to know that the last found delimiter was a '<' or '>'.  As
    // a result, "2" can be a TIONumber token type instead of a TWord
    // token type. 
    //
    //
    // "If the string consists solely of digits and the delimiter character
    // is one of '<' or '>', the token identifier IO_NUMBER (TIONumber)
    // shall be returned".  Taken from:
    //
    // https://pubs.opengroup.org/onlinepubs/009604499/utilities/xcu_chap02.html#tag_02_10
    //
    bool del;
} Lex;

// Token represents a token or text string returned from the lexer.
typedef struct __sToken {
    char *text;			// String representation of the token.
    Type type;			// Type of the current token.
} Token;

Lex *lex_make(void);
void lex_readfrom(const char *);
Token *lex_next(void);
