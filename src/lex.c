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
    l->seen[0] = TEOF;
    l->seen[1] = TEOF;
    l->seen[2] = TEOF;
    l->done = true;
    return l;
}

// lex_readfrom sets Lex->buf to point to the provided input by the
// caller and reset Lex->pos, Lex->stt, and Lex->done to its zero values.
void lex_readfrom(const char *input)
{
    l->buf = input;
    l->pos = 0;
    l->stt = 0;
    l->done = false;
}

// next returns the next character in the buf.
static char next(void)
{
    if (!l->buf[l->pos]) {
	l->done = true;
    }

    char c = l->buf[l->pos];
    l->pos++;
    return c;
}

// peek returns but does not consume the next character in the buf.
static char peek(void)
{
    char c = next();
    l->pos--;
    return c;
}

// ignore skips over the pending buf before this point.
static void ignore(void)
{
    l->stt = l->pos;
}

// emit returns a token back to the caller.
static Token *emit(TokenType type)
{
    // Update the three last seen token types.
    l->seen[2] = l->seen[1];
    l->seen[1] = l->seen[0];
    l->seen[0] = type;

    // Prepare the current token.
    Token *t = malloc(sizeof(Token));
    t->type = type;

    int n = l->pos - l->stt;
    t->text = malloc(sizeof(char) * (n + 1));
    t->text[n] = '\0';

    strncpy(t->text, l->buf + l->stt, n);
    l->stt = l->pos;
    return t;
}

// lex_next returns the next token available in buf.
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

	    // These are all of the possible characters a keyword can start with.
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
	    // buf, which means, there is no more buf to read from.
	    return emit(TEOF);
	}
    }
}

// lex_keyword scans:  TIf      TThen    TElse    TElif    TFi   TDo   TDone.
//                     'if'     'then'   'else'   'elif'   'fi'  'do'  'done'
//
//                     TCase    TEsac    TWhile   TUntil   TFor
//                     'case'   'esac'   'while'  'until'  'for'
//
//                     TLBrace  TRBrace  TBang
//                     '{'      '}'      '!'
static Token *lex_keyword(void)
{
    for (;;) {
	switch (peek()) {

	default:

	    // If calling peek() doesn't give a character of the set of the 
	    // character that a keyword can have in it or a space character,
	    // continue processing the token as a TWord.
	    return lex_word();

	    // These are all of the possible characters that 
	    // no-a-single-character keyword can have in it.
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

	case ' ':
	case '\t':
	case '\v':
	case '\f':
	case '\r':
	case '\n':
	case '\0':
	    Token * t = emit(TWord);

	    // At this point, we have a t->text which has only characters 
	    // of the set of characters that a keyword can have in it. We
	    // have to make sure it is a keyword, otherwise, it is a Word.
	    TokenType type = keyw_typeof(t->text);

	    // The type of a 'in' token is a TIn if and only if the third 
	    // last token type is TFor or TCase.
	    if (type == TIn && l->seen[2] != TFor && l->seen[2] != TCase) {
		type = TWord;
	    }
	    // Update the current seen token type.
	    l->seen[0] = type;
	    t->type = type;
	    return t;
	}
    }
}


// lex_word scans any TWord.
static Token *lex_word(void)
{
    for (;;) {
	switch (peek()) {

	default:
	    next();
	    break;

	    // Stop scanning when any of these delimiters is found.
	case ' ':
	case '\t':
	case '\v':
	case '\f':
	case '\r':
	case '\n':
	case '\0':
	case '<':
	case '>':
	    return emit(TWord);
	}
    }
}

// lex_and scans: TAnd  TAndIf.
//                '&'   '&&'
static Token *lex_and(void)
{
    // &&
    if (peek() == '&') {
	next();
	return emit(TAndIf);
    }
    // &
    return emit(TAnd);
}

// lex_or scans: TOr  TOrIf.
//               '|'  '||'
static Token *lex_or(void)
{
    // ||
    if (peek() == '|') {
	next();
	return emit(TOrIf);
    }
    // |
    return emit(TOr);
}

// lex_semi scans: TSemi  TDSemi.
//                 ';'    ';;'
static Token *lex_semi(void)
{
    // ;;
    if (peek() == ';') {
	next();
	return emit(TDSemi);
    }
    // ;
    return emit(TSemi);
}

// lex_number scans an integer positive number that could be Tword or
// TIONumber.
static Token *lex_number(void)
{
    Token *t;
    for (;;) {
	switch (peek()) {

	default:

	    t = emit(TWord);

	    // At this point Lex->stt and Lex->pos are pointing at the start and
	    // at the end of the current positive integer in the buf line:
	    //
	    // Lex->buf = [ x | x | x | 1 | 2 | x | x | \0 ]
	    //                            ^       ^
	    //                            |       |
	    //                           stt     pos
	    //
	    // But we still don't know what type of tokin it is. It could be TWord or
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

    char c = peek();

    // If the next character in buf is  a '<' or '>', the next token
    // could be: "<", ">", "<<", ">>", "<&", ">&", "<>", "<<-", or ">|".
    // Hence, the current token is a TIONumber.
    if (c == '<' || c == '>') {
	t->type = TIONumber;
    }

    return t;
}

// lex_less scans:  TLess  TDLess  TLessAnd  TDLessDash  TLessGreat.
//                  '<'    '<<'    '<&'      '<<-'       '<>'
static Token *lex_less(void)
{
    switch (peek()) {

	// <
    default:
	return emit(TLess);

	// << or <<-
    case '<':
	next();
	// <<-
	if (peek() == '-') {
	    next();
	    return emit(TDLessDash);
	}
	// <<
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

// lex_space consumes the space characters.
static void lex_space(void)
{
    for (;;) {
	switch (peek()) {

	default:
	    ignore();
	    return;

	    // These are space characters.
	case ' ':
	case '\t':
	case '\v':
	case '\f':
	case '\r':
	case '\n':
	    next();
	    break;
	}
    }
}
