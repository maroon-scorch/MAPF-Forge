#lang forge/core

(require "mapf.rkt")

(run wellformed-graphs
     #:preds [wellFormed]
     )

(define answer-model (forge:get-result wellformed-graphs))
(define first-answer (tree:get-value answer-model))

(print (node-left answer-model))

;;; (define (foldTree proc init lst)
;;;   (cond
;;;     [(null? lst) init]
;;;     [else
;;;      (proc (car lst)
;;;            (foldTree proc init (caddr lst))
;;;            (foldTree proc init (cadddr lst)))]))

;;; (define (solve graph)
;;;     (solved (forge:is-sat? 
;;;         (run solvability
;;;         #:preds [traces solved]
;;;         #:bounds graph
;;;         )))
;;; )

;;; (define wfSolved (for/last ([each-graph wellformed-graphs])
;;;     (run solvability
;;;      #:preds [traces solved]
;;;      #:bounds each-graph
;;;     )
;;;     (define solved (forge:is-sat? solvability))
;;;     #:final (not solved)
;;;     solved
;;; ))

;;; (print solved)

;;; (define answer-model (forge:get-result answers))
;;; (define first-answer (tree:get-value answer-model))
;;; (print first-answer)
;;; (display wfSolved)