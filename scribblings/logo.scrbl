#lang scribble/manual

@(require scribble/bnf
          (for-label logo/language))

@title{Logo}

@table-of-contents[]

@section[#:tag "lang"]{Logo language}

@defmodulelang[logo]

@subsection{Program grammar}

@BNF[(list @nonterm{program}
           @kleenestar{@nonterm{statement}})]

A Logo program is a sequence of statements separated by whitespace.
Comments begin with @litchar{;} and continue until the end of the line.

@subsubsection{Statements}

@BNF[(list @nonterm{statement}
           @nonterm{procedure-definition}
           @nonterm{procedure-call}
           @BNF-seq{@litchar{if} @nonterm{test-expr} @nonterm{block}}
           @BNF-seq{@litchar{repeat} @nonterm{count-expr} @nonterm{block}})
     (list @nonterm{block}
           @BNF-seq{@litchar{[} @kleenestar{@nonterm{statement}} @litchar{]}})]


@subsubsection{Procedures}

@BNF[(list @nonterm{procedure-definition}
           @BNF-seq{@litchar{to}
                    @nonterm{identifier}
                    @kleenestar{@nonterm{parameter}}
                    @kleenestar{@nonterm{statement}}
                    @litchar{end}})
     (list @nonterm{procedure-call}
           @BNF-seq{@nonterm{identifier} @nonterm{arg-expr}})
     (list @nonterm{parameter}
           @elem{an identifier prefixed with @litchar{:}})]

@subsubsection{Expressions}

@BNF[(list @nonterm{expression}
           @elem{numeric literal}
           @nonterm{parameter}
           @BNF-seq{@nonterm{expression} @nonterm{operator} @nonterm{expression}})
     (list @nonterm{operator}
           @BNF-alt[@litchar{+} @litchar{-} @litchar{*} @litchar{/}
                    @litchar{=} @litchar{<} @litchar{>}])]

@section{Built-in procedures}

@declare-exporting[logo/language]

@subsection{Turtle graphics}

@deftogether[(@defform[(forward d)]
              @defform[(fd d)])]{
Move forward @racket[d] units.
}

@deftogether[(@defform[(backward d)]
              @defform[(bk d)])]{
Move backward @racket[d] units.
}

@defform[(left φ)]{
Turn left (anticlockwise) @racket[φ] degrees.
}

@defform[(right φ)]{
Turn right (clockwise) @racket[φ] degrees.
}

@deftogether[(@defform[(penup)]
              @defform[(pu)])]{
Raise the turtle's pen so that lines are not drawn when moving.
}

@deftogether[(@defform[(pendown)]
              @defform[(pd)])]{
Lower the turtle's pen to draw lines.
}

@defform[(home)]{
Return to the origin in a straight line.
}

@deftogether[(@defform[(clearscreen)]
              @defform[(cs)])]{
Clear the screen.
}

@section{Examples}

The file @tt{sierpinski.rkt} in this package shows how to
draw a Sierpinski triangle using turtle graphics.