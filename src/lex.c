//
// lex.c - lexical analysis
//

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "lex.h"

Lex *lex_make(void);
void lex_readfrom(const char *);
Token *lex_next(void);
static char next(void);
static char peek(void);
static void ignore(void);
static Token *emit(Type);
static Token *lex_number(void);
static Token *lex_and(void);
static Token *lex_or(void);
static Token *lex_semi(void);
static Token *lex_less(void);
static Token *lex_great(void);
static void lex_space(void);
static bool is_space(const char);

// ---------------------------------------------------------------------------

static Lex *l;

// lex_make allocates and returns a Lex struct. Its field are just read-only,
// make sure not setting any of its fields.  lex_make has to be called before
// using the rest of public functions listen in "lex.h".
Lex *lex_make(void)
{
    l = malloc(sizeof(Lex));
    l->pos = 0;
    l->stt = 0;
    l->done = true;
    l->del = false;
    return l;
}

// lex_readfrom sets Lex->input to point to the new input provided by the
// caller and reset Lex->pos, Lex->stt, and Lex->done to its zero values.
void lex_readfrom(const char *input)
{
    l->input = input;
    l->pos = 0;
    l->stt = 0;
    l->done = false;
    l->del = false;
}

// lex_next returns the next token available in input.
Token *lex_next(void)
{
    for (;;) {
	switch (next()) {

	default:
	    return emit(TWord);

	case '\0':

	    // The null-terminated character has already been reached from the
	    // input, which means, there is no more input to read from.
	    return emit(TEOF);

	case '\n':
	    l->del = false;
	    return emit(TNewLine);

	case '&':
	    l->del = false;
	    return lex_and();

	case '|':
	    l->del = false;
	    return lex_or();

	case ';':
	    l->del = false;
	    return lex_semi();

	case '<':
	    l->del = true;
	    return lex_less();

	case '>':
	    l->del = true;
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
	case '\t':
	case '\v':
	case '\f':
	case '\r':
	    lex_space();
	    break;
	}
    }
}

// next returns the next character in the input.
static char next(void)
{
    if (!l->input[l->pos]) {
	l->done = true;
    }

    char c = l->input[l->pos];
    l->pos++;
    return c;
}

// peek returns but does not consume the next character in the input.
static char peek(void)
{
    char c = next();
    l->pos--;
    return c;
}

// ignore skips over the pending input before this point.
static void ignore(void)
{
    l->stt = l->pos;
}

// emit returns a token back to the caller.
static Token *emit(Type type)
{
    Token *t = malloc(sizeof(Token));
    t->type = type;

    if (type == TNewLine || type == TEOF) {
	l->stt = l->pos;
	t->text = "";
	return t;
    }

    int n = l->pos - l->stt;
    t->text = malloc(sizeof(char) * (n + 1));
    t->text[n] = '\0';

    strncpy(t->text, l->input + l->stt, n);
    l->stt = l->pos;
    return t;
}

static Token *lex_and(void)
{
    if (peek() == '&') {
	next();
	return emit(TAndIf);
    }

    return emit(TAnd);
}

static Token *lex_or(void)
{
    if (peek() == '|') {
	next();
	return emit(TOrIf);
    }

    return emit(TOr);
}

static Token *lex_semi(void)
{
    if (peek() == ';') {
	next();
	return emit(TDSemi);
    }

    return emit(TSemi);
}


// lex_number scans an integer positive number: Tword  TIONumber.
static Token *lex_number(void)
{
    Token *t;
    for (;;) {
	switch (peek()) {

	default:

	    t = emit(TWord);

	    // At this point Lex->stt and Lex->pos are pointing at the start and
	    // at the end of the current positive integer in the input line:
	    //
	    // Lex->input = [ x | x | x | 1 | 2 | x | x | \0 ]
	    //                            ^       ^
	    //                            |       |
	    //                           stt     pos
	    //
	    // But we still don't know what type of tokin is it. It could be TWord or
	    // TIONumber. Consequently, we don't return inmediatly the token; the analysis
	    // continues.
	    goto Loop;

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
  Loop:

    // See: https://pubs.opengroup.org/onlinepubs/009604499/utilities/xcu_chap02.html#tag_02_10
    //
    // if Lex->del is set to true, the previous found token has a '<' or 
    // '>' in its string representation, making this number to be 
    // delimited by '<' or '>'. Therefore, the token type is IO_NUMBER.
    if (l->del) {
	t->type = TIONumber;
	l->del = false;
	return t;
    }

    lex_space();

    // After skipping the spaces, we look if this token is delimited by '<'
    // or '>'.
    char c = peek();
    if (c == '<' || c == '>') {
	t->type = TIONumber;
    }

    return t;
}

// lex_less scans:  TLess  TDLess TLessAnd TDLessDash  TLessGreat.
//                 '<'    '<<'   '<&'     '<<-'       '<>'
static Token *lex_less(void)
{
    switch (peek()) {

	// <
    default:
	return emit(TLess);

	// << or <<-
    case '<':
	next();
	if (peek() == '-') {
	    next();
	    return emit(TDLessDash);
	}

	return emit(TDLess);

	// <&
    case '&':
	next();
	return emit(TLessAnd);

	// <>
    case '>':
	next();
	return emit(TLessGreat);
    }
}

// lex_less scans:  TGreat  TDGreat  TGreatAnd  TLobber.
//                  '>'     '>>'     '>&'       '>|'
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

	// >|
    case '|':
	next();
	return emit(TLobber);
    }
}

// lex_space consumes the space characteres.
static void lex_space(void)
{
    while (is_space(peek())) {
	next();
    }
    ignore();
}

// is_space reports whether c is a space character.
static bool is_space(const char c)
{
    return c == ' ' || c == '\t' || c == '\v' || c == '\f' || c == '\r';
}
