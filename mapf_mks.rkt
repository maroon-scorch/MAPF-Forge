; Special Special Thanks to Thomas for Providing the Basic Syntax Help on Doing this in Forge/Core
#lang forge/core

; Given a sample Multi-Agent Pathfinding Problem, this script
; finds a solution to the problem with the optimal makespan.

; Loading the Constraint Solver:
(require "mapf.rkt")
; (require "instances.rkt")

(run sat-test
     #:preds [traces solved]
     #:bounds structure
     )

(unless (forge:is-sat? sat-test)
  (raise "The Problem given has no solutions."))

(define answers (for/last ([n (in-naturals 1)]) 
    (set-option! 'max_tracelength n)
    (run solvability
     #:preds [traces solved]
     #:bounds structure
    )
    #:final (forge:is-sat? solvability)
    solvability
))


(define answer-model (forge:get-result answers))
(define first-answer (tree:get-value answer-model))
(print first-answer)
(display answers)