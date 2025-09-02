; GDScript formatting queries for Topiary
; This is an early work-in-progress!

; Add a space after keywords
[
  "class_name" "extends" "var" "func" "class"
  "if" "elif" "else" "for" "while"
  "const" "return" "match" "signal" "enum"
  "await" "remote" "master" "puppet" "remotesync"
  "mastersync" "puppetsync"
  (static_keyword)]
@append_space

; Preserve comments and strings as they are
(comment) @leaf
(string) @leaf

; TYPE ANNOTATION SPACING
(typed_parameter ":" @append_space)
(typed_default_parameter ":" @append_space)
(variable_statement ":" @append_space)

; ARRAY AND DICTIONARY
; If the array is on a single line, only insert spaces between values. If it's
; multi-line, format it with new lines.
(array
  "[" @append_empty_softline @append_indent_start
  "]" @prepend_empty_softline @append_empty_softline @prepend_indent_end)

(array "," @append_spaced_softline)
(dictionary
  "{" @append_empty_softline @append_indent_start
  "}" @prepend_empty_softline @append_empty_softline @prepend_indent_end)

(dictionary "," @append_spaced_softline)
(pair ":" @append_space)

; FUNCTIONS
(function_definition (name) @append_antispace)
(function_definition (body) @prepend_hardline)
(arguments "," @append_space)
"->" @prepend_space @append_space
(parameters "," @append_space)
; MULTI-LINE PARAMETERS
(parameters
    "(" @append_hardline @append_indent_start
    ")" @prepend_hardline @prepend_indent_end
    (#multi_line_only!))
(parameters
    ([(typed_parameter) (typed_default_parameter) (identifier) (default_parameter)]) @prepend_hardline @prepend_indent_start @append_indent_end
    (#multi_line_only!))

; CLASS DEFINITIONS
(class_definition (body) @prepend_hardline)
(class_name_statement) @append_space
(source
    (extends_statement) @append_delimiter @append_hardline
    (#delimiter! "\n"))
(extends_statement) @prepend_space

; EMPTY LINES BETWEEN DEFINITIONS
;
; Add 2 newlines between top-level property definitions and function definitions
; Note: the . between nodes constrains the query to direct siblings (instead of
; matching a series of indirect siblings like e.g. variable + class + ... +
; function)
([(variable_statement) (function_definition) (class_definition) (signal_statement) (const_statement) (enum_definition) (constructor_definition)]
    .
    [(function_definition) (constructor_definition) (class_definition)] @prepend_delimiter @prepend_hardline
    (#delimiter! "\n"))

; CONST DEFINITIONS
(const_statement ":" @append_space)

; ENUMS
(enumerator_list
  "{" @append_input_softline @append_indent_start
  "}" @prepend_input_softline @prepend_indent_end)
(enumerator_list "," @append_spaced_softline)
(enumerator_list) @prepend_space

; CONSTRUCTORS
(constructor_definition (body) @prepend_hardline)

; OPERATORS
; Allow line breaks around binary operators for long expressions
; This means that if the programmer has a long expression, they can break it up by wrapping something on a line
(binary_operator
  [
    "+" "-" "*" "/" "%" "**"
    "==" "!=" "<" ">" "<=" ">=" "and"
    "or" "in" "is" "&&" "||"]
  @prepend_input_softline @append_input_softline)
; Comparison operators (+ "as" keyword which needs the same spacing)
[
    "==" "!=" "<" ">" "<=" ">="
    "and" "or" "in" "is" "as"]
@prepend_space @append_space
; not can be at the start of an expression, so we handle it separately - needs another query for the case "is not"
"not" @append_space
; Bitwise operators
[
  "&" "|" "^" "<<" ">>"]
@prepend_space @append_space
; ~ is generally right next to the variable it operates on, so we don't add a space before it
"~" @append_space
[
    "=" ":=" "+=" "-=" "*=" "/=" "%=" "**=" "&=" "|=" "^=" "<<=" ">>="]
@prepend_space @append_space

; CONTROL FLOW FORMATTING
; Colons in control structures - remove space before colon
(if_statement ":" @prepend_antispace)
(elif_clause ":" @prepend_antispace)
(else_clause ":" @prepend_antispace)
(for_statement "in" ":" @prepend_antispace)
(while_statement ":" @prepend_antispace)

(if_statement (body) @prepend_hardline)
(elif_clause (body) @prepend_hardline)
(else_clause (body) @prepend_hardline)
(for_statement (body) @prepend_hardline)
(while_statement (body) @prepend_hardline)

((identifier) . ":" @append_space . (type))

; Make sure the body of control structures is indented (the preprended and
; appended indents target the body)
((body) @prepend_indent_start @append_indent_end)

([(return_statement)
  (pass_statement)
  (breakpoint_statement)
  (break_statement)
  (continue_statement)
  (tool_statement)
  (enum_definition)
  (const_statement)
  (signal_statement)
  (variable_statement)
  (expression_statement)
  (if_statement)
  (elif_clause)
  (else_clause)
  (for_statement)
  (while_statement)
  (match_statement)] @append_empty_softline
 . (comment)? @do_nothing)

(comment) @append_empty_softline @prepend_input_softline

; Allow one blank line before following statements
([(return_statement)
  (pass_statement)
  (breakpoint_statement)
  (break_statement)
  (continue_statement)
  (tool_statement)
  (enum_definition)
  (const_statement)
  (signal_statement)
  (variable_statement)
  (expression_statement)
  (if_statement)
  (elif_clause)
  (else_clause)
  (for_statement)
  (while_statement)
  (match_statement)
  (comment)
  (annotation)] @allow_blank_line_before)

; tree-sitter parses @tool statement as an annotation node for some reason instead of tool_statement
(source . (annotation) @append_hardline)

(setget) @prepend_indent_start @append_indent_end
(setget ":" @prepend_antispace)
(setget ":" @append_hardline . (comment)? @do_nothing)
; why body node in set_body/get_body not getting new indent even though we added indent to all body node?
(set_body ":" @prepend_antispace @append_indent_start)
(set_body ":" @append_hardline . (comment)? @do_nothing)
(get_body ":" @prepend_antispace @append_indent_start)
(get_body ":" @append_hardline . (comment)? @do_nothing)
((set_body) @append_hardline @append_indent_end)
((get_body) @append_hardline @append_indent_end)

(match_statement ":" @prepend_antispace)
(match_body) @prepend_indent_start @append_indent_end @prepend_hardline
(pattern_section ":" @prepend_antispace)
(pattern_section (body) @prepend_hardline)
(pattern_section "," @prepend_antispace @append_space)

; This is for ternary expressions, e.g. `a if b else c`
(conditional_expression [("if") ("else")] @prepend_space @append_space)
(parenthesized_expression (conditional_expression ("else") @prepend_input_softline))
(conditional_expression (conditional_expression ("else") @prepend_input_softline))

(parenthesized_expression "(" @append_antispace)
(parenthesized_expression
 "(" @append_input_softline @append_indent_start
 ")" @prepend_input_softline @prepend_indent_end
 (#multi_line_only!))

; LAMBDA
(lambda ":" @append_space (#single_line_only!))
(lambda ":" @append_hardline . (comment)? @do_nothing (#multi_line_only!))
(lambda (parameters "(" @prepend_antispace))

; ANNOTATIONS
; we again are using @append_space capture name, but this time we
; need to make sure to not add additional space between identifier and open paren
(annotation) @append_space
((annotation (identifier) @append_space) @append_empty_softline (#not-match? @append_space "^(onready|export)$"))
(annotation (arguments "(" @prepend_antispace))
(function_definition (annotations (annotation) @append_hardline))

; This is used to preserve new lines after semicolons for people who use them on
; all code lines
(";") @append_hardline
