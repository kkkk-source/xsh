//
// lex.h - lexical analysis
//

#ifndef LEX_H
#define LEX_H

#include <stdio.h>
#include <stdbool.h>

typedef enum {
    TEOF,			// End of file
    TWord,			// Any
    TIONumber,			// Integer positive number delimited by '<' or '>'
    TNewLine,			// \n

    TAnd,			// &
    TOr,			// |
    TSemi,			// ;
    TAndIf,			// &&
    TOrIf,			// ||
    TDSemi,			// ;;
    TLess,			// <
    TGreat,			// >
    TDLess,			// <<
    TDGreat,			// >>
    TLessAnd,			// <&
    TGreatAnd,			// >&
    TLessGreat,			// <>
    TDLessDash,			// <<-
    TLobber,			// >|

    TIf,			// if
    TThen,			// then
    TElse,			// else
    TElif,			// elif
    TFi,			// fi
    TDo,			// do
    TDone,			// done
    TCase,			// case
    TEsac,			// esac
    TWhile,			// while
    TUntil,			// until
    TFor,			// for

    TLBrace,			// {
    TRBrace,			// }
    TBang,			// !

    TIn,			// in
} TokenType;

// Lex holds the state of the lexer.
typedef struct __sLex {

    // buf is used to store the current input string under examination. 
    const char *buf;

    // Lex->buf = [ x | x | x | x | x | x | x | \0 ]
    //                                    ^
    //                                    |
    //                                   pos
    //
    // pos is the position in the buf of the current character under
    // examination.
    size_t pos;

    // Lex->buf = [ x | x | x | x | x | x | x | \0 ]
    //                    ^           ^
    //                    |           |
    //                   stt         pos
    //
    // stt is the start position of the substring under examination. This
    // substring is supposed to be the text value of the field of a token. 
    size_t stt;

    // seen is used to keep track of the last seen three token types. seen is
    // useful to determine whether the text 'in' is a TIn or TWord. If the
    // current text is 'in' and the third last seen token type was a TFor
    // or TCase, then the token type of 'in' is TIn. Otherwise, it's TWord.
    TokenType seen[3];

    // done is set to true if there is no more characters in the buf to
    // read from. It is just set to false when lex_readfrom() get called.
    bool done;

} Lex;

// Token represents a token returned from the lexer.
typedef struct __sToken {

    // text is the string representation of the current token.  text is getting
    // by extracting the substring in between of Lex->stt and Lex->pos:
    //
    // Lex->buf = [ x | f | o | r | x | x | x | \0 ]
    //                    ^           ^
    //                    |           |
    //                   stt         pos
    // gives: 'for'
    //
    char *text;

    // type is the token type of the current token.
    TokenType type;

    size_t col;

} Token;

Lex *lex_make(void);
void lex_readfrom(const char *);
Token *lex_next(void);

#endif
