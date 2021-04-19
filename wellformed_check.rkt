#lang forge/core

(require "mapf.rkt")

(run wellformed-graphs
     #:preds [wellformed]
     )

(define answer-model (forge:get-result answers))
(define first-answer (tree:get-value answer-model))
(print first-answer)
(display wellformed-graphs)