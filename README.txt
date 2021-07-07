/* -------------------------------------------------------
   The grammar symbols
   ------------------------------------------------------- */
%token  WORD
%token  NEWLINE
%token  IO_NUMBER

/* The following are the operators (see XBD Operator)
   containing more than one character. */

%token  AND_IF    OR_IF    DSEMI
/*      '&&'      '||'     ';;'    */

%token  DLESS  DGREAT  LESSAND  GREATAND  LESSGREAT  DLESSDASH
/*      '<<'   '>>'    '<&'     '>&'      '<>'       '<<-'   */

%token  CLOBBER
/*      '>|'   */

/* The following are the reserved words. */

%token  If    Then    Else    Elif    Fi    Do    Done
/*      'if'  'then'  'else'  'elif'  'fi'  'do'  'done'   */

%token  Case    Esac    While    Until    For
/*      'case'  'esac'  'while'  'until'  'for'   */

/* These are reserved words, not operator tokens, and are
   recognized when reserved words are recognized. */

%token  Lbrace    Rbrace    Bang
/*      '{'       '}'       '!'   */

%token  In
/*      'in'   */

/* -------------------------------------------------------
   The Grammar
   ------------------------------------------------------- */

program          : complete_command linebreak
                 | linebreak
                 ;
complete_command : list separator_op
                 | list
                 ;

list             : pipeline list'
list'            | separator_op pipeline list'
                 | /* empty */
                 ;

separator_op     : '&'
                 | ';'
                 ;
pipeline         :      pipe_sequence
                 | Bang pipe_sequence
                 ;

pipe_sequence    : command pipe_sequence'
pipe_sequence'   | '|' linebreak command pipe_sequence'
                 | /* empty */
                 ;

command          : simple_command
                 ;
simple_command   : cmd_prefix cmd_word cmd_suffix
                 | cmd_prefix cmd_word
                 | cmd_prefix
                 | cmd_name cmd_suffix
                 | cmd_name
                 ;
cmd_name         : WORD                   /* Apply rule 7a */
                 ;
cmd_word         : WORD                   /* Apply rule 7b */
                 ;

cmd_prefix       | io_redirect     cmd_prefix'
                 | ASSIGNMENT_WORD cmd_prefix'
cmd_prefix'      | io_redirect     cmd_prefix'
                 | ASSIGNMENT_WORD cmd_prefix'
                 | /* empty */
                 ;

cmd_suffix       | io_redirect cmd_suffix'
                 | WORD        cmd_suffix'
cmd_suffix'      | io_redirect cmd_suffix'
                 | WORD        cmd_suffix'
                 | /* empty */
                 ;

io_redirect      :           io_file
                 | IO_NUMBER io_file
                 |           io_here
                 | IO_NUMBER io_here
                 ;
io_file          : '<'       filename
                 | LESSAND   filename
                 | '>'       filename
                 | GREATAND  filename
                 | DGREAT    filename
                 | LESSGREAT filename
                 | CLOBBER   filename
                 ;
filename         : WORD                      /* Apply rule 2 */
                 ;
io_here          : DLESS     here_end
                 | DLESSDASH here_end
                 ;
here_end         : WORD
                 ;

newline_list     | NEWLINE newline_list'
newline_list'    : NEWLINE newline_list'
                 | /* empty */
                 ;

linebreak        : newline_list
                 | /* empty */
                 ;
