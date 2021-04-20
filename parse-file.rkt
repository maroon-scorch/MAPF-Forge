#lang forge/core
;;; IO Handling Provided by Thomas

(require (for-syntax racket))
(provide to-inst to-inst-command-line)

(begin-for-syntax
    (struct Node (name))
    (struct Edge (from to value))
    (struct Agent (name start end))
    (struct Data (nodes edges agents))
    (define (get-data filename)
    (with-input-from-file filename 
        (lambda ()
        (define num-nodes (read))
        (define num-agents (read))
        (read-line)
        (define-values (nodes edges)
            (for/fold ([nodes '()] [edges '()])
                    ([n (in-range num-nodes)])
                (define line (string-split (read-line)))
                (define-values (node edge-tos) (values (first line) (rest line)))
                (define vals (string-split (read-line)))
                (define new-node (Node node))
                (define new-edges (for/list ([edge edge-tos] [val vals]) (Edge node edge val)))
                (values (append nodes (list new-node)) (append edges new-edges))))
        (define agents
            (for/list ([n (in-range num-agents)])
            (define parts (string-split (read-line)))
            (apply Agent parts)))
        (Data nodes edges agents)))))

(define-syntax (to-inst stx)
  (syntax-case stx ()
    [(to-inst filename)
     (let ([data (get-data (syntax->datum #'filename))])
     ; ([data (get-data (syntax->datum #'filename))])
        (define body
            ; Node = Node1 + Node2 + Node3 + Node4
            (list
                `(= Node ,(for/fold ([body 'none]) 
                                ([node (Data-nodes data)]) 
                        `(+ ,body ,(string->symbol (Node-name node)))))

                ; Edge = Edge12 + Edge13 + Edge14
                `(= Edge ,(for/fold ([body 'none])
                                    ([n (in-naturals)]
                                    [edge (Data-edges data)])
                            `(+ ,body ,(string->symbol (format "Edge~a" n)))))
                            
                ; edges = Node1->Edge12 + Node1->Edge13 + Node1->Edge14
                `(= edges ,(for/fold ([body '(-> none none)])
                                    ([n (in-naturals)]
                                    [edge (Data-edges data)])
                            `(+ ,body (-> ,(string->symbol (Edge-from edge))
                                        ,(string->symbol (format "Edge~a" n))))))

                ; to = Edge12->Node2 + Edge13->Node3 + Edge14->Node4
                `(= to ,(for/fold ([body '(-> none none)])
                                ([n (in-naturals)]
                                    [edge (Data-edges data)])
                            `(+ ,body (-> ,(string->symbol (format "Edge~a" n))
                                        ,(string->symbol (Edge-to edge))))))
                ; value = ...
                `(= value ,(for/fold ([body '(-> none none)])
                                    ([n (in-naturals)]
                                    [edge (Data-edges data)])
                            `(+ ,body (-> ,(string->symbol (format "Edge~a" n))
                                        ,(string->number (Edge-value edge))))))

                ; Agent = AgentA
                `(= Agent ,(for/fold ([body 'none])
                                    ([n (in-naturals)]
                                    [agent (Data-agents data)])
                            `(+ ,body ,(string->symbol (Agent-name agent)))))

                ; start = AgentA->Node1
                `(= start ,(for/fold ([body '(-> none none)])
                                    ([n (in-naturals)]
                                    [agent (Data-agents data)])
                            `(+ ,body (-> ,(string->symbol (Agent-name agent))
                                        ,(string->symbol (Agent-start agent))))))

                ; dest = AgentA->Node4
                `(= dest ,(for/fold ([body '(-> none none)])
                                    ([n (in-naturals)]
                                    [agent (Data-agents data)])
                            `(+ ,body (-> ,(string->symbol (Agent-name agent))
                                        ,(string->symbol (Agent-end agent))))))))
        #`(let () (inst temp-inst #,@(datum->syntax stx body)) temp-inst)
     )
     ]))

(define-syntax (to-inst-command-line stx)
  (syntax-case stx ()
    [(to-inst-command-line)
     (let ([args (current-command-line-arguments)])
       (unless (>= (vector-length args) 1)
         (raise "Usage: racket mapf_solver.rkt <path_to_file>"))
       (let ([filename (vector-ref args 0)])
         (datum->syntax stx `(to-inst ,filename))))]))