#include <stdbool.h>
#include "lex.h"

#define LENGTH 12

static char *keywords[LENGTH] = {
    "if",
    "then",
    "else",
    "elif",
    "fi",
    "do",
    "done",
    "case",
    "esac",
    "until",
    "while",
    "for",
};

static int keywordtypes[LENGTH] = {
    TIf,
    TThen,
    TElse,
    TElif,
    TFi,
    TDo,
    TDone,
    TCase,
    TEsac,
    TUntil,
    TWhile,
    TFor,
};

TokenType keyw_gettype(const char *);
static bool streq(const char *, const char *);

// ---------------------------------------------------------------------------

// keyw_typeof returns the TokenType of the keyword provided.  If the
// provided keyword is, actually, not a keyword, keyw_gettype returns the type
// TWord.
TokenType keyw_typeof(const char *keyword)
{
    for (int i = 0; i < LENGTH; i++) {
	if (streq(keyword, keywords[i])) {
	    return keywordtypes[i];
	}
    }
    return TWord;
}

// streq checks whether s1 and s2 are equal.
static bool streq(const char *s1, const char *s2)
{
    while (*s1) {
	s1++;
	s2++;

	if (*s1 != *s2) {
	    return false;
	}
    }
    return true;
}
