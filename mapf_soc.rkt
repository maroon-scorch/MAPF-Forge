; Special Special Thanks to Thomas for helping us on this in Forge/Core
#lang forge/core

; Load the forge spec in
(require "mapf.rkt")
(require "parse-file.rkt")
; (require "instances.rkt")
; (option 'max-tracelength n)

(define answers (for/last ([n (in-naturals 1)]) 
    (set-option! 'max_tracelength n)
    (define my-inst (to-inst "input.txt"))
    (run solvability
     #:preds [traces solved]
     #:bounds my-inst
    )
    #:final (forge:is-sat? solvability)
    solvability
))

;; (< (sing (constant 5)) (sing (constant 6)))
;; myFunc
;; (myFunc (sing (int 5)))



(define answer-model (forge:get-result answers))
(define first-answer (tree:get-value answer-model))
(print first-answer)
(display answers)