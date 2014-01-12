#lang racket

(provide parse-logo)

(require parser-tools/lex
         parser-tools/yacc
         (prefix-in : parser-tools/lex-sre))

(define-tokens tokens (QUOTE VAR-REF ID NUMBER))
(define-empty-tokens empty-tokens (LB RB + - * / < > = TO END IF REPEAT EOL EOF WS))

(define-lex-abbrev identifier
  (:: alphabetic (:? quoted-identifier)))

(define-lex-abbrev quoted-identifier
  (:+ (:~ (:or whitespace #\; #\" #\: #\[ #\]))))

(define logo-lexer
  (lexer-src-pos
   [(:: #\; (:* (:~ #\newline)))
    (token-WS)]
   [(:: #\" quoted-identifier)
    (token-QUOTE (string->symbol
                  (substring lexeme 1)))]   
   [(:: #\: quoted-identifier)
    (token-VAR-REF (string->symbol
                    (substring lexeme 1)))]
   [identifier
    (let ([sym (string->symbol (string-downcase lexeme))])
      (case sym
        [(to) (token-TO)]
        [(end) (token-END)]
        [(if) (token-IF)]
        [(repeat) (token-REPEAT)]
        [else (token-ID sym)]))]
   [(:+ numeric) (token-NUMBER (string->number lexeme))]
   [#\[ (token-LB)]
   [#\] (token-RB)]
   [#\+ (token-+)]
   [#\- (token--)]
   [#\* (token-*)]
   [#\/ (token-/)]
   [#\= (token-=)]
   [#\< (token-<)]
   [#\> (token->)]
   [#\newline (token-EOL)]
   [(:+ whitespace) (token-WS)]
   [(eof) (token-EOF)]))

(define (parse-logo src in)
  
  (define (token-getter)
    (let next-token ()
      (define pt (logo-lexer in))
      (case (token-name (position-token-token pt))
        [(WS) (next-token)]
        [else pt])))
  
  (define (decorate datum start-pos end-pos)
    (datum->syntax #f datum
                   (list src
                         (position-line start-pos)
                         (position-col start-pos)
                         (position-offset start-pos)
                         (- (position-offset end-pos)
                            (position-offset start-pos)))))
  
  (define parse
    (parser
     (tokens tokens empty-tokens)
     (start program)
     (end EOF)
     (error
      (lambda (tok-ok? tok-name tok-value start-pos end-pos)
        (raise
         (make-exn:fail:read "parse error"
                             (current-continuation-marks)
                             (list (make-srcloc src
                                                (position-line start-pos)
                                                (position-col start-pos)
                                                (position-offset start-pos)
                                                (- (position-offset end-pos)
                                                   (position-offset start-pos))))))))
     (precs (left * / + -))
     (src-pos)
     (grammar
      (program [(stmt-list) (datum->syntax #f `(begin . ,$1))]
               [() eof])
      (block [(LB stmt-list RB) $2])
      (maybe-eol [() #f]
                 [(EOL maybe-eol) #t])
      (stmt-list [(stmt) `(,$1)]
                 [(stmt stmt-list) `(,$1 . ,$2)])
      (stmt [(stmt EOL) $1]
            [(ID maybe-expr-list)
             (decorate `(,$1 . ,$2) $1-start-pos $2-end-pos)]
            [(TO ID maybe-arg-list maybe-eol stmt-list END)
             (decorate `(define (,$2 . ,$3) . ,$5)
                       $1-start-pos $6-end-pos)]
            [(IF test-expr block)
             (decorate `(when ,$2 . ,$3) $1-start-pos $3-end-pos)]
            [(REPEAT expr block)
             (decorate `(repeat ,$2 . ,$3) $1-start-pos $3-end-pos)])
      (maybe-arg-list [() '()]
                      [(arg-list) $1])
      (arg-list [(arg) `(,$1)]
                [(arg arg-list) `(,$1 . ,$2)])
      (arg [(VAR-REF) (decorate $1 $1-start-pos $1-end-pos)])
      (maybe-expr-list [() '()]
                       [(expr-list) $1])
      (expr-list [(expr) `(,$1)]
                 [(expr expr-list) `(,$1 . ,$2)])
      (expr [(VAR-REF) (decorate $1 $1-start-pos $1-end-pos)]
            [(NUMBER) (decorate $1 $1-start-pos $1-end-pos)]
            [(expr + expr) (decorate `(+ ,$1 ,$3) $1-start-pos $3-end-pos)]
            [(expr - expr) (decorate `(- ,$1 ,$3) $1-start-pos $3-end-pos)]
            [(expr * expr) (decorate `(* ,$1 ,$3) $1-start-pos $3-end-pos)]
            [(expr / expr) (decorate `(/ ,$1 ,$3) $1-start-pos $3-end-pos)])
      (test-expr [(expr = expr) (decorate `(= ,$1 ,$3) $1-start-pos $3-end-pos)]
                 [(expr < expr) (decorate `(< ,$1 ,$3) $1-start-pos $3-end-pos)]
                 [(expr > expr) (decorate `(> ,$1 ,$3) $1-start-pos $3-end-pos)]))))
  
  (parse token-getter))
