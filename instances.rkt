#lang forge

open "mapf.rkt"

inst notCollide {
    Node = Node0 + Node1 + Node2
    Edge = Edge01 + Edge10 + Edge12 + Edge20
    edges = Node0->Edge01 + Node1->Edge10 + Node1->Edge12 + Node2->Edge20
    to = Edge01->Node1 + Edge10->Node0 + Edge12->Node2 + Edge20->Node0

    Agent = Agent0 + Agent1
    start = Agent0->Node0 + Agent1->Node1
    dest = Agent0->Node1 + Agent1->Node0
}