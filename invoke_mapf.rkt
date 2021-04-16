; Special Thanks to Thomas for Providing the Basic Syntax Help on Doing this in Forge/Core
#lang forge/core

; Load the forge spec in
(require "test.rkt")

; Create a run
(run my-run1
     #:preds [(some ([n Node]) (isSource n))])

; Ensure the run is sat
; Note: this is where forge actually solves the problem.
(unless (forge:is-sat? my-run1)
  (raise "Model is unsat!"))

; Get the first instance
(define result (forge:get-result my-run1))
(define first-model (tree:get-value result))
(define instance (first (forge:Sat-instances first-model)))

; Retrieve the edges relation from the first instance
(println (hash-ref instance 'edges))