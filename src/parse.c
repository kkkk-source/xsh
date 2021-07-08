//
// parse.c - parser
//

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "lex.h"
#include "parse.h"

Parser *parser_make(Lex *);
void parser_parse(void);
static bool accept(TokenType);
static bool expect(TokenType);
static void parse_program(void);
static void parse_complete_command(void);
static void parse_list(void);
static void parse_list_prime(void);
static void parse_separator_op(void);
static void parse_pipeline(void);
static void parse_pipe_sequence(void);
static void parse_pipe_sequence_prime(void);
static void parse_command(void);
static void parse_simple_command(void);
static void parse_cmd_name(void);
static void parse_cmd_suffix(void);
static void parse_cmd_suffix_prime(void);
static void parse_io_redirect(void);
static void parse_io_file(void);
static void parse_filename(void);
static void parse_io_here(void);
static void parse_newline_list(void);
static void parse_newline_list_prime(void);
static void parse_linebreak(void);

// ---------------------------------------------------------------------------

static Parser *parser;

Parser *parser_make(Lex * lex)
{
    parser = malloc(sizeof(Parser));
    parser->lex = lex;
    return parser;
}

// parser_parse checks if the textual input provided by the Lexer is
// syntactically correct.
void parser_parse(void)
{
    parser->lah = lex_next();
    parse_program();
}

static Token *parse_next_token()
{
    return lex_next();
}

// accept checks whether the Parser->lah is the expected token type. If
// so, it avances the token Parse->lah. 
static bool accept(TokenType type)
{
    if (expect(type)) {
	parser->lah = parse_next_token();
	return true;
    }

    return false;
}

// expect checks whether the Parser->lah is the expected token type.
static bool expect(TokenType type)
{
    return parser->lah->type == type;
}

// program               : complete_command linebreak
//                       | linebreak
//                       ;
static void parse_program(void)
{
    if (expect(TNewLine)) {
	parse_linebreak();
    }

    parse_complete_command();
    parse_linebreak();
}

// complete_command      : list separator_op
//                       | list
//                       ;
static void parse_complete_command(void)
{
    parse_list();

    if (expect(TAnd) || expect(TOr)) {
	parse_separator_op();
    }
}

// list                  : pipeline list_prime
//                       ;
static void parse_list(void)
{
    parse_pipeline();
    parse_list_prime();
}

// list_prime            : separator_op pipeline list_prime
//                       | /* eps */
//                       ;
static void parse_list_prime(void)
{
    if (expect(TAnd) || expect(TOr)) {
	parse_separator_op();
	parse_pipeline();
	parse_list_prime();
	return;
    }
}

// separator_op          : AND
//                       | SEMI
//                       ;
static void parse_separator_op(void)
{
    if (accept(TAnd) || accept(TOr)) {
	return;
    }

    fprintf(stderr, "newline_list: error at col=%ld, got='%s'\n",
	    parser->lah->col, parser->lah->text);
}

// pipeline              :      pipe_sequence
//                       | Bang pipe_sequence
//                       ;
static void parse_pipeline(void)
{
    if (accept(TBang));

    parse_pipe_sequence();
}

// pipe_sequence         : command pipe_sequence_prime
//                       ;
static void parse_pipe_sequence(void)
{
    parse_command();
    parse_pipe_sequence_prime();
}

// pipe_sequence_prime   : OR linebreak command pipe_sequence_prime
//                       | /* eps */
//                       ;
static void parse_pipe_sequence_prime(void)
{
    if (accept(TOr)) {
	parse_linebreak();
	parse_command();
	parse_pipe_sequence_prime();
	return;
    }
}

// command               : simple_command
//                       ;
static void parse_command(void)
{
    parse_simple_command();
}

// simple_command        | cmd_name cmd_suffix
//                       | cmd_name
//                       ;
static void parse_simple_command(void)
{
    if (expect(TWord)) {
	parse_cmd_name();

	switch (parser->lah->type) {

	default:
	    break;

	case TIONumber:
	case TLess:
	case TLessAnd:
	case TGreat:
	case TGreatAnd:
	case TDGreat:
	case TLessGreat:
	case TLobber:
	case TDLess:
	case TDLessDash:
	    parse_cmd_suffix();
	}

	return;
    }
    fprintf(stderr, "simple_command: error at col=%ld, got='%s'\n",
	    parser->lah->col, parser->lah->text);
}

// cmd_suffix            : io_redirect cmd_suffix_prime
//                       | WORD        cmd_suffix_prime
//                       ;
static void parse_cmd_suffix(void)
{
    parse_io_redirect();
    parse_cmd_suffix_prime();
}

// cmd_suffix_prime      : io_redirect cmd_suffix_prime
//                       | WORD        cmd_suffix_prime
//                       | /* eps */
//                       ;
static void parse_cmd_suffix_prime()
{

    switch (parser->lah->type) {

    default:
	break;

    case TIONumber:
    case TLess:
    case TLessAnd:
    case TGreat:
    case TGreatAnd:
    case TDGreat:
    case TLessGreat:
    case TLobber:
    case TDLess:
    case TDLessDash:
	parse_io_redirect();
	parse_cmd_suffix_prime();
	return;
    }

    if (accept(TWord)) {
	parse_cmd_suffix_prime();
	return;
    }
}

// io_redirect           :           io_file
//                       | IO_NUMBER io_file
//                       |           io_here
//                       | IO_NUMBER io_here
//                       ;
static void parse_io_redirect()
{
    if (accept(TIONumber)) {
	switch (parser->lah->type) {

	default:
	    break;

	case TLess:
	case TLessAnd:
	case TGreat:
	case TGreatAnd:
	case TDGreat:
	case TLessGreat:
	case TLobber:
	    parse_io_file();
	    return;
	}

	if (expect(TDLess) || expect(TDLessDash)) {
	    parse_io_here();
	    return;
	}

	fprintf(stderr, "io_redirect: error\n");
	return;
    }

    switch (parser->lah->type) {

    default:
	break;

    case TLess:
    case TLessAnd:
    case TGreat:
    case TGreatAnd:
    case TDGreat:
    case TLessGreat:
    case TLobber:
	parse_io_file();
	return;
    }

    if (expect(TDLess) || expect(TDLessDash)) {
	parse_io_here();
	return;
    }

    fprintf(stderr, "io_redirect: error at col=%ld, got='%s'\n",
	    parser->lah->col, parser->lah->text);
}

// io_file               : LESS      filename
//                       | LESSAND   filename
//                       | GREAT     filename
//                       | GREATAND  filename
//                       | DGREAT    filename
//                       | LESSGREAT filename
//                       | CLOBBER   filename
//                       ;
static void parse_io_file(void)
{
    switch (parser->lah->type) {

    default:
	fprintf(stderr, "io_file: error at col=%ld, got='%s'\n",
		parser->lah->col, parser->lah->text);
	return;

    case TLess:
    case TLessAnd:
    case TGreat:
    case TGreatAnd:
    case TDGreat:
    case TLessGreat:
    case TLobber:
	parse_filename();
	return;
    }
}

// filename              : WORD
//                       ;
static void parse_filename(void)
{
    if (!accept(TWord)) {
	fprintf(stderr, "filename: error at col=%ld, got='%s'\n",
		parser->lah->col, parser->lah->text);
	return;
    }
}

// io_here               : DLESS     here_end
//                       | DLESSDASH here_end
//                       ;
static void parse_io_here(void)
{
    if (!accept(TDLess) || !accept(TDLessDash)) {
	fprintf(stderr, "io_here: error at col=%ld, got='%s'\n",
		parser->lah->col, parser->lah->text);
    }
}

// cmd_name              : WORD
//                       ;
static void parse_cmd_name(void)
{
    if (!accept(TWord)) {
	fprintf(stderr, "newline_list: error at col=%ld, got='%s'\n",
		parser->lah->col, parser->lah->text);
	return;
    }
}

// newline_list          : NEWLINE newline_list_prime
//                       ;
static void parse_newline_list(void)
{
    if (accept(TNewLine)) {
	parse_newline_list_prime();
	return;
    }

    fprintf(stderr, "newline_list: error at col=%ld, got='%s'\n",
	    parser->lah->col, parser->lah->text);
}

// newline_list_prime    : NEWLINE newline_list_prime
//                       | /* eps */
//                       ;
static void parse_newline_list_prime(void)
{
    if (accept(TNewLine)) {
	parse_newline_list_prime();
	return;
    }
}

// linebreak             : newline_list
//                       | /* eps */
//                       ;
static void parse_linebreak(void)
{
    if (expect(TNewLine)) {
	parse_newline_list();
	return;
    }
}
