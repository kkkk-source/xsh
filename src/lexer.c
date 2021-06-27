#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "lexer.h"

static Lex *l;

Lex *lex_make(void)
{
    l = malloc(sizeof(Lex));
    l->pos = 0;
    l->start = 0;
    l->done = false;
    return l;
}

void lex_readfrom(const char *input)
{
    l->input = input;
    l->pos = 0;
    l->start = 0;
    l->done = false;
}

static char next(void)
{
    if (!l->input[l->pos]) {
	l->done = true;
    }

    char c = l->input[l->pos];
    l->pos++;
    return c;
}

static char peek(void)
{
    char c = next();
    l->pos--;
    return c;
}

static Token *emit(Type type)
{
    Token *t = malloc(sizeof(Token));
    t->type = type;

    int n = l->pos - l->start;
    t->text = malloc(sizeof(char) * (n + 1));
    t->text[n] = '\0';

    strncpy(t->text, l->input + l->start, n);
    l->start = l->pos;
    return t;
}

static void ignore(void)
{
    l->start = l->pos;
}

static bool is_space(const char c)
{
    return c == ' ' || c == '\n' || c == '\t';
}

static void lex_space(void)
{
    while (is_space(peek())) {
	next();
    }
    ignore();
}

static Token *lex_number(void)
{
    for (;;) {
	switch (peek()) {

	default:
	    return emit(TIONumber);

	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
	    next();
	    break;
	}
    }
}

static Token *lex_less(void)
{
    switch (peek()) {

	// <
    default:
	return emit(TLess);

	// <<
    case '<':
	next();
	return emit(TDLess);

	// <&
    case '&':
	next();
	return emit(TLessAnd);
    }
}

static Token *lex_great(void)
{
    switch (peek()) {

	// >
    default:
	return emit(TGreat);

	// >>
    case '>':
	next();
	return emit(TDGreat);

	// >&
    case '&':
	next();
	return emit(TGreatAnd);
    }
}

Token *lex_next(void)
{
    for (;;) {
	switch (next()) {

	default:
	    return emit(TUNK);

	case '\0':
	    return emit(TEOF);

	case '&':
	    return emit(TAnd);

	case '<':
	    return lex_less();

	case '>':
	    return lex_great();

	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
	    return lex_number();

	case ' ':
	case '\n':
	case '\t':
	    lex_space();
	    break;
	}
    }
}
