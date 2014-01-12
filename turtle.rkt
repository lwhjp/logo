#lang racket/base

(require math
         (prefix-in turtles: graphics/value-turtles))

(provide make-turtle
         with-turtle
         forward
         backward
         right
         left
         clearscreen
         penup
         pendown
         home
         (rename-out [forward fd]
                     [backward bk]
                     [right rt]
                     [left lt]
                     [clearscreen cs]
                     [penup pu]
                     [pendown pd]))

(struct turtle (z θ pen-down? frame) #:mutable)

(define current-turtle (make-parameter #f))

(define (make-turtle [width 400] [height 300])
  (turtle (make-rectangular 0 0)
          0
          #t
          (turtles:turtles width height)))

(define (with-turtle turtle thunk)
  (parameterize ([current-turtle turtle])
    (thunk))
  (turtle-frame turtle))

(define (forward n)
  (let ([t (current-turtle)])
    (set-turtle-z! t
      (+ (turtle-z t)
         (make-polar n (turtle-θ t))))
    (set-turtle-frame! t
      (if (turtle-pen-down? t)
          (turtles:draw n (turtle-frame t))
          (turtles:move n (turtle-frame t))))))

(define (backward n)
  (forward (- n)))

(define (right φ)
  (turn/radians (degrees->radians (- φ))))

(define (left φ)
  (turn/radians (degrees->radians φ)))

(define (turn/radians φ)
  (let ([t (current-turtle)])
    (set-turtle-θ! t (+ (turtle-θ t) φ))
    (set-turtle-frame! t
      (turtles:turn/radians φ (turtle-frame t)))))

(define (clearscreen)
  (let ([t (current-turtle)])
    (set-turtle-z! (make-rectangular 0 0))
    (set-turtle-θ! 0)
    (set-turtle-frame! (turtles:clean (turtle-frame t)))))

(define (penup)
  (set-turtle-pen-down?! (current-turtle) #f))

(define (pendown)
  (set-turtle-pen-down?! (current-turtle) #t))

(define (home)
  (let* ([t (current-turtle)]
         [z (turtle-z t)]
         [θ (angle z)])
    (turn/radians (- θ (turtle-θ t)))
    (backward (magnitude z))
    (turn/radians (- θ))))
