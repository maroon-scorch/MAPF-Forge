#lang forge
sig Node {
  edges: set Node
}

pred isSource[n: Node] {
  all n2: Node | n->n2 in edges
}