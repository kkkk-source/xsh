#include <stdio.h>
#include <stdbool.h>

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


typedef struct __sLex {
    const char *input;
    int pos;			// Current position in input.
    int start;			// Start position of current token.
    bool done;			// If true, there is no more to read from.
} Lex;

typedef struct __sToken {
    char *text;			// String representation.
    Type type;			// Type of token.
} Token;

Lex *lex_make(void);
void lex_readfrom(const char *);
Token *lex_next(void);
