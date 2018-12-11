#lang s-exp syntax/module-reader
logo/language
#:read read-logo
#:read-syntax read-logo-syntax

(require "../parser.rkt")

(define (read-logo in)
  (syntax->datum (read-logo-syntax #f in)))

(define (read-logo-syntax src in)
  (parse-logo src in))
