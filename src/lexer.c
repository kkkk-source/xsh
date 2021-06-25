typedef enum {
	TWord,
	TIo_number,
	TNewline,
	TAnd,       // &
	TLess,      // <
	TGreat,     // >
	TDless,     // <<
	TDgreat,    // >>
	TLessand,   // <&
	TGreatand,  // >&

	TLessgreat, // <>  *
	TDlessdash, // <<- *
} Type ;

struct Token {
	char * lexeme; // String representation.
	Type   type;   // Type of token.
	int    line;   // Line number on which the token appears.
};

struct Lexer {
	char * input; // Input to read from.
	int    line;  // Line number.
	int    pos;   // Current position in input.
	int    start; // Start position of current token.
	bool   done;  // If true, there is no more to read from.
};


struct * Lexer l = NULL;

void lexer_new() {
}

void lexer_clean() {
}

static void load_line() {
}

static char next() {
	if (!l->load && !l->input[l->pos]) {
		load_line(l);
	}
	if (!l->input[l->pos]) {
		return NULL;
	}

	char c = l->input[l->pos];
	l->pos = l->post + 1;
	return c;
}

static char peek() {
	char c = l->next();
	l->pos = l->pos - 1;
	return c;
}

static struct * Token emit(Type t) {
	if (t == TNewline) {
		l->line = l->line + 1;
	}

	char * s[l->pos - l->start];
	strncpy(s, l->line + l->start, l->pos)

	t = { .lexeme = s, .type = t, .line = l->line };
	l->start = l->pos;
	return t;
}

// lexer_next stores the next token into the provided token t.
struct * Token lexer_next() {
	for (;;) {
		switch (next()) {

			case '&':
				return emit(TAnd);

			case '<':
				if (peek() == '<') return emit(TDless);   // <<
				if (peek() == '&') return emit(TLessand); // <&
				return emit(TLess);

			case '>':
				if (peek() == '>') return emit(TDgreat);   // >>
				if (peek() == '&') return emit(TGreatand); // >&
				return emit(TGreat);

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
				return emit(TIo_number);

			case '\n':
				return emit(TNewline)
		}
	}
}
