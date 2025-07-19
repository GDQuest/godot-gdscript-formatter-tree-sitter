; GDScript formatting queries for Topiary
; This is an early work-in-progress!

; Add a space after keywords
[
  "class_name" "extends" "var" "func" "class"
  "if" "elif" "else" "for" "while"
  "const" "return" "match"
] @append_space

; Preserve comments and strings as they are
(comment) @leaf @append_hardline
(string) @leaf

; TYPE ANNOTATION SPACING
(typed_parameter ":" @append_space)
(typed_default_parameter ":" @append_space)
(variable_statement ":" @append_space)

; PARAMETER SPACING
(parameters "," @append_space)

; ARRAY AND DICTIONARY FORMATTING
; If the array is on a single line, only insert spaces between values. If it's
; multi-line, format it with new lines.
(array
  "[" @append_empty_softline @append_indent_start
  "]" @prepend_empty_softline @append_empty_softline @prepend_indent_end
)
(array "," @append_spaced_softline)

(dictionary
  "{" @append_empty_softline @append_indent_start
  "}" @prepend_empty_softline @append_empty_softline @prepend_indent_end
)
(dictionary "," @append_spaced_softline)
(pair ":" @append_space)


; FUNCTIONS
(arguments "," @append_space)
"->" @prepend_space @append_space
(class_name_statement) @append_space
(annotation) @append_space

(function_definition (name) @append_antispace)
(function_definition ":" @append_hardline)

(class_definition ":" @append_hardline)

; EMPTY LINES BETWEEN DEFINITIONS
;
; Add 2 newlines between top-level property definitions and function definitions
; Note: the . between nodes constrains the query to direct siblings (instead of
; matching a series of indirect siblings like e.g. variable + class + ... +
; function)
(source
    (variable_statement) @append_delimiter
    .
    (function_definition)
    (#delimiter! "\n\n")
)
(source
    (function_definition) @append_delimiter
    .
    (function_definition)
    (#delimiter! "\n\n")
)
(source
    (function_definition) @append_delimiter
    .
    (class_definition)
    (#delimiter! "\n\n")
)
(source
    (class_definition) @append_delimiter
    .
    (function_definition)
    (#delimiter! "\n\n")
)

; Add an empty line between extends and the first property definition
(source
    (extends_statement) @append_delimiter
    .
    (variable_statement)
    (#delimiter! "\n\n")
)

; Add an empty line between different kinds of property definitions
; The goal is to detect groups of exported vars and regular vars, and
; add a newline between them.
; FIXME: this won't work because variable_statement matches every property
(source
    (variable_statement
        (annotations)
    ) @append_delimiter
    .
    (variable_statement)
    (#delimiter! "\n")
)

; This is the same as above but it aims to match vars without annotations followed
; by vars with annotations.
(source
    (variable_statement) @append_delimiter
    .
    (variable_statement
        (annotations)
    )
    (#delimiter! "\n")
)

(class_definition) @append_hardline

(class_definition
  (body) @prepend_indent_start @append_indent_end
)
(function_definition
  (body) @prepend_indent_start @append_indent_end
)
(variable_statement) @append_hardline

; Allow line breaks around binary operators for long expressions
; This means that if the programmer has a long expression, they can break it up by wrapping something on a line
(binary_operator
  [
    "+" "-" "*" "/" "%" "**"
    "==" "!=" "<" ">" "<=" ">=" "and"
    "or" "in" "is"
  ] @prepend_spaced_softline @append_spaced_softline
)

; OPERATORS
; Calculation operators (restrict to binary operator context to avoid added spaces in other contexts)
(binary_operator [
    "+" "-" "*" "/" "%" "**"
]) @prepend_space @append_space
; Comparison operators
[
    "==" "!=" "<" ">" "<=" ">="
    "and" "or" "in" "is"
] @prepend_space @append_space
; not can be at the start of an expression, so we handle it separately - needs another query for the case "is not"
"not" @append_space
; Bitwise operators
[
  "&" "|" "^" "<<" ">>"
] @prepend_space @append_space
; ~ is generally right next to the variable it operates on, so we don't add a space before it
"~" @append_space
[
    "=" ":=" "+=" "-=" "*=" "/=" "%=" "**=" "&=" "|=" "^=" "<<=" ">>="
] @prepend_space @append_space

; CONTROL FLOW FORMATTING
; Colons in control structures - remove space before colon
(if_statement ":" @prepend_antispace @append_hardline)
(elif_clause ":" @prepend_antispace @append_hardline)
(else_clause ":" @prepend_antispace @append_hardline)
(for_statement ":" @prepend_antispace @append_hardline)
(while_statement ":" @prepend_antispace @append_hardline)

; Make sure the body of control structures is indented (the preprended and
; appended indents target the body)
(if_statement (body) @prepend_indent_start @append_indent_end)
(elif_clause (body) @prepend_indent_start @append_indent_end)
(else_clause (body) @prepend_indent_start @append_indent_end)
(for_statement (body) @prepend_indent_start @append_indent_end)
(while_statement (body) @prepend_indent_start @append_indent_end)

(expression_statement) @append_hardline
