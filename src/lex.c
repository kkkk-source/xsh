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
static void lex_comment(void);
static void lex_space(void);

// ---------------------------------------------------------------------------

static Lex *lex;

// lex_make allocates and returns a Lex struct. Its field are just read-only,
// make sure not setting any of its fields.  lex_make has to be called before
// using the rest of public functions listen in "lex.h".
Lex *lex_make(void)
{
    lex = malloc(sizeof(Lex));
    lex->pos = 0;
    lex->stt = 0;
    lex->seen[0] = TEOF;
    lex->seen[1] = TEOF;
    lex->seen[2] = TEOF;
    lex->done = true;
    return lex;
}

// lex_readfrom sets Lex->buf to point to the provided input by the
// caller and reset Lex->pos, Lex->stt, and Lex->done to its zero values.
void lex_readfrom(const char *input)
{
    lex->buf = input;
    lex->pos = 0;
    lex->stt = 0;
    lex->done = false;
}

// next returns the next character in the buf.
static char next(void)
{
    if (!lex->buf[lex->pos]) {
	lex->done = true;
    }

    char c = lex->buf[lex->pos];
    lex->pos++;
    return c;
}

// peek returns but does not consume the next character in the buf.
static char peek(void)
{
    char c = next();
    lex->pos--;
    return c;
}

// ignore skips over the pending buf before this point.
static void ignore(void)
{
    lex->stt = lex->pos;
}

// emit returns a token back to the caller.
static Token *emit(TokenType type)
{
    // Update the three last seen token types.
    lex->seen[2] = lex->seen[1];
    lex->seen[1] = lex->seen[0];
    lex->seen[0] = type;

    // Prepare the current token.
    Token *tok = malloc(sizeof(Token));
    tok->type = type;

    int n_chars = lex->pos - lex->stt;
    tok->text = malloc(sizeof(char) * (n_chars + 1));
    tok->text[n_chars] = '\0';
    tok->col = lex->stt + 1;

    strncpy(tok->text, lex->buf + lex->stt, n_chars);
    lex->stt = lex->pos;
    return tok;
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

	case '#':

	    // If the current character is a '#', it and all subsequent 
	    // characters up to, but excluding, the next newline shall
	    // be discarded as a comment.
	    lex_comment();
	    break;

	case ' ':
	case '\t':
	case '\v':
	case '\f':
	case '\r':
	    lex_space();
	    break;

	case '\n':
	    return emit(TNewLine);

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
	    Token * tok = emit(TWord);

	    // At this point, we have a t->text which has only characters 
	    // of the set of characters that a keyword can have in it. We
	    // have to make sure it is a keyword, otherwise, it is a Word.
	    TokenType type = keyw_typeof(tok->text);

	    // The type of a 'in' token is a TIn if and only if the third 
	    // last token type is TFor or TCase.
	    TokenType third_seen = lex->seen[2];
	    if (type == TIn && third_seen != TFor && third_seen != TCase) {
		type = TWord;
	    }
	    // Update the current seen token type and the current 
	    // Lex->seen token if type is a keyword.
	    if (type != TWord) {
		lex->seen[0] = type;
		tok->type = type;
	    }

	    return tok;
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
	case '#':
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
    for (;;) {
	switch (peek()) {

	default:

	    Token * tok = emit(TWord);

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
	    // Consume all spaces.
	    lex_space();

	    char c = peek();

	    // If the next character in buf is  a '<' or '>', the next token
	    // could be: "<", ">", "<<", ">>", "<&", ">&", "<>", "<<-", or ">|".
	    // Hence, the current token is a TIONumber.
	    if (c == '<' || c == '>') {
		tok->type = TIONumber;
	    }

	    return tok;

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

// lex_comment ignores the characters that are part of a comment, excluding the
// newline character.
static void lex_comment(void)
{
    for (;;) {
	switch (peek()) {

	default:
	    next();
	    break;

	    // The newline that ends the line is not considered part of the comment.
	case '\n':
	    ignore();
	    return;
	}
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
	    next();
	    break;
	}
    }
}
