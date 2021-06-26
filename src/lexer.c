#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "lexer.h"

#define MAX_LINE_LENGTH 8

struct Lexer {
    char input[MAX_LINE_LENGTH];
    FILE *src;			// Source file to extract input from. 
    int pos;			// Current position in input.
    int start;			// Start position of current token.
    bool done;			// If true, there is no more to read from.
};

static struct Lexer *l = NULL;

void lexer_new(FILE * src)
{
    l = malloc(sizeof(struct Lexer));
    l->src = src;
    l->pos = 0;
    l->start = 0;
    l->done = false;
}

static void load_line(void)
{
    if (!fgets(l->input, MAX_LINE_LENGTH, l->src)) {
	l->done = true;
    }

    l->pos = 0;
    l->start = 0;
}

static char next(void)
{
    if (!l->done && !l->input[l->pos]) {
	load_line();
    }

    if (!l->input[l->pos]) {
	return '\0';
    }

    char c = l->input[l->pos];
    l->pos = l->pos + 1;
    return c;
}

static char peek(void)
{
    char c = next();
    l->pos = l->pos - 1;
    return c;
}

static struct Token *emit(Type type)
{
    int n = l->pos - l->start;
    char text[n + 1];
    strncpy(text, l->input + l->start, n);
    text[n] = '\0';

    l->start = l->pos;

    struct Token *t = malloc(sizeof(struct Token));
    t->text = text;
    t->type = type;
    return t;
}

static struct Token *lexAnd(void)
{
    return emit(TAnd);
}

static struct Token *lexNumber(void)
{
    for (;;) {
	switch (next()) {

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
	    break;
	}
    }
}

static struct Token *lexLess(void)
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

static struct Token *lexGreat(void)
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

struct Token *lexer_next(void)
{
    for (;;) {
	switch (next()) {

	default:
	    return emit(TUNK);

	case '\0':
	    return emit(TEOF);

	case '&':
	    return lexAnd();

	case '<':
	    return lexLess();

	case '>':
	    return lexGreat();

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
	    return lexNumber();

	case '\n':
	    break;
	}
    }
}
