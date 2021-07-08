#ifndef PARSE_H
#define PARSE_H

#include "lex.h"

typedef struct _sParser {
    Lex *lex;
    Token *lah;			// lookahead token
} Parser;

Parser *parser_make(Lex *);
void parser_parse(void);

#endif
