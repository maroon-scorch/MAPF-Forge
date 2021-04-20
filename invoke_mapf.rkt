; Special Special Thanks to Thomas for helping us on this in Forge/Core
#lang forge/core

; Load the forge spec in
(require "mapf.rkt")
(require "parse-file.rkt")
; (require "instances.rkt")
; (option 'max-tracelength n)

; (define problem (to-inst "input.txt"))
(define problem (to-inst-command-line))

(define answers (for/last ([n (in-naturals 1)]) 
    (set-option! 'max_tracelength n)
    (run solvability
     #:preds [traces solved]
     #:bounds problem
    )
    #:final (forge:is-sat? solvability)
    solvability
))

;;; ;; (< (sing (constant 5)) (sing (constant 6)))
;;; ;; myFunc
;;; ;; (myFunc (sing (int 5)))



(define answer-model (forge:get-result answers))
(define first-answer (tree:get-value answer-model))
(print first-answer)
(display answers)

;;; ; Create a run
;;; (run my-run1
;;;      #:preds [(some ([n Node]) (isSource n))])

;;; ; Ensure the run is sat
;;; ; Note: this is where forge actually solves the problem.
;;; (unless (forge:is-sat? my-run1)
;;;   (raise "Model is unsat!"))

;;; ; Get the first instance
;;; (define result (forge:get-result my-run1))
;;; (define first-model (tree:get-value result))
;;; (define instance (first (forge:Sat-instances first-model)))

;;; ; Retrieve the edges relation from the first instance
;;; (println (hash-ref instance 'edges))