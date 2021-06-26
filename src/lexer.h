#include <stdio.h>

typedef enum {
    TEOF,
    TUNK,

    TWord,
    TIONumber,
    TNewLine,

    TAnd,			// &
    TLess,			// <
    TGreat,			// >
    TDLess,			// <<
    TDGreat,			// >>
    TLessAnd,			// <&
    TGreatAnd,			// >&

    TLessGreat,			// <>  *
    TDLessDash,			// <<- *
} Type;

struct Token {
    char *text;			// String representation.
    Type type;			// Type of token.
};

void lexer_new(FILE *);
struct Token *lexer_next(void);
