; Special Special Thanks to Thomas for Providing the Syntax Help on Doing this in Forge/Core
#lang forge/core

; Given a sample Multi-Agent Pathfinding Problem, this script
; finds a solution to the problem with the optimal makespan.

; Loading the Constraint Solver:
(require "mapf.rkt")
(require "parse-file.rkt")

; Grabs the filename from the Command Line
(define problem (to-inst-command-line))

; Iterate through the stream of positive natural numbers:
(define answers (for/last ([n (in-naturals 1)])
    ; Increment the max_tracelength by 1 each time
    (set-option! 'max_tracelength n)
    (run solvability
     #:preds [traces solved]
     #:bounds problem
    )
    ; Exits the first time the instance is sat
    #:final (forge:is-sat? solvability)
    solvability
))

; The Answer is guaranteed to be Optimal since every case with a trace_length
; below the current trace_length is unsat.
(display answers)

; Showing the Answers in Console:
;;; (define answer-model (forge:get-result answers))
;;; (define first-answer (tree:get-value answer-model))
;;; (print first-answer)