//
// lex.h - lexical analysis
//

#include <stdio.h>
#include <stdbool.h>

typedef enum {
    TEOF, // End Of File
    TUNK, // Unknown

    TIONumber,

    TAnd,			// &
    TLess,			// <
    TGreat,			// >
    TDLess,			// <<
    TDGreat,			// >>
    TLessAnd,			// <&
    TGreatAnd,			// >&
} Type;

// Lex holds the state of the lexer.
typedef struct __sLex {
    const char *input;
    int pos;			// Current position in the provided input.
    int start;			// Start position of current token's c-string.
    bool done;			// If true, the current input has been consume.
} Lex;

// Token represents a token or text string returned from the lexer.
typedef struct __sToken {
    char *text;			// String representation of the token.
    Type type;			// Type of the current token.
} Token;

Lex *lex_make(void);
void lex_readfrom(const char *);
Token *lex_next(void);
