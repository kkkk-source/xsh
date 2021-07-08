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

    fprintf(stderr, "separator_op: error\n");
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

// simple_command        : cmd_name
//                       ;
static void parse_simple_command(void)
{
    parse_cmd_name();
}

// cmd_name              : WORD
//                       ;
static void parse_cmd_name(void)
{
    if (!accept(TWord)) {
	fprintf(stderr, "simple_command: error\n");
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

    fprintf(stderr, "newline_list: error\n");
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
