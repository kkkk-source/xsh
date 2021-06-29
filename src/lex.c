//
// lex.c - lexical analysis
//

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "lex.h"
#include "keyw.h"

Lex *lex_make(void);
void lex_readfrom(const char *);
Token *lex_next(void);
static char next(void);
static char peek(void);
static void ignore(void);
static Token *emit(TokenType);
static Token *lex_keyword(void);
static Token *lex_word(void);
static Token *lex_number(void);
static Token *lex_and(void);
static Token *lex_or(void);
static Token *lex_semi(void);
static Token *lex_less(void);
static Token *lex_great(void);
static void lex_space(void);

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
static Token *emit(TokenType type)
{
    Token *t = malloc(sizeof(Token));
    t->type = type;

    if (type == TNewLine) {
	l->stt = l->pos;
	t->text = "\\n";
	return t;
    }

    if (type == TEOF) {
	l->stt = l->pos;
	t->text = "eof";
	return t;
    }

    int n = l->pos - l->stt;
    t->text = malloc(sizeof(char) * (n + 1));
    t->text[n] = '\0';

    strncpy(t->text, l->input + l->stt, n);
    l->stt = l->pos;
    return t;
}

// lex_next returns the next token available in input.
Token *lex_next(void)
{
    for (;;) {
	switch (next()) {

	default:
	    return lex_word();

	case '&':
	    return lex_and();

	case '|':
	    return lex_or();

	case ';':
	    return lex_semi();

	case '<':
	    return lex_less();

	case '>':
	    return lex_great();

	case 'i':
	case 't':
	case 'e':
	case 'f':
	case 'd':
	case 'c':
	case 'u':
	case 'w':
	case '{':
	case '}':
	case '!':
	    return lex_keyword();

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
	case '\n':
	    lex_space();
	    break;

	case '\0':

	    // The null-terminated character has already been reached from the
	    // input, which means, there is no more input to read from.
	    return emit(TEOF);
	}
    }
}

static Token *lex_keyword(void)
{
    for (;;) {
	switch (peek()) {

	default:
	    next();
	    return lex_word();

	case ' ':
	case '\t':
	case '\v':
	case '\f':
	case '\r':
	case '\n':
	case '\0':
	    Token * t = emit(TWord);
	    t->type = keyw_typeof(t->text);
	    return t;

	case 'a':
	case 'c':
	case 'd':
	case 'e':
	case 'f':
	case 'h':
	case 'i':
	case 'l':
	case 'n':
	case 'o':
	case 'r':
	case 's':
	case 't':
	case 'u':
	case 'w':
	    next();
	    break;
	}
    }
}

static Token *lex_word(void)
{
    for (;;) {
	switch (peek()) {

	default:
	    next();
	    break;

	case ' ':
	case '\t':
	case '\v':
	case '\f':
	case '\r':
	case '\n':
	case '\0':
	    return emit(TWord);
	}
    }
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

    // Consume all spaces.
    lex_space();

    // If the next character in input is '<' or '>', the current token is a
    // TIONumber.
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
    for (;;) {
	switch (peek()) {

	default:
	    ignore();
	    return;

	case ' ':
	case '\t':
	case '\v':
	case '\f':
	case '\r':
	case '\n':
	    next();
	}
    }
}
