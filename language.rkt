#lang racket/base

(require "turtle.rkt")

(provide (all-from-out "turtle.rkt")
         (except-out (all-defined-out)
                     module-begin)
         (rename-out [module-begin #%module-begin])
         #%app
         #%datum
         #%top
         define
         begin
         when
         quote
         + - * /
         < = >
         random
         sqrt
         exp
         (rename-out [expt power]
                     [log ln]))

(define-syntax-rule (module-begin expr ...)
  (#%module-begin
   (with-turtle (make-turtle)
     (lambda ()
       expr ...))))

(define-syntax-rule (block expr ...)
  (lambda ()
    expr ...))

(define-syntax-rule (repeat n expr ...)
  (do ([i 0 (add1 i)])
    ((>= i n) (void))
    expr ...))

(define (print datum)
  (displayln datum))

(define e (exp 1))

(define (log10 z)
  (/ (log z)
     (log 10)))
