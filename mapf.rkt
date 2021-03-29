#lang forge

option problem_type temporal
option max_tracelength 20

/*
--------------------------------------
Final Project - Multi-Agent Pathfinding
--------------------------------------
*/

/*
--------------------------------------
Node:
"Node" is used to represent a stop on a Graph
by which the Agent would be operating on,
with the following property:

@edges - The set of edges extending out of the Node.
--------------------------------------
*/
sig Node {
    edges: set Edge
}

/*
--------------------------------------
Edge:
"Edge" is used to represent the relation from one Node
to another, by which the Agent would be traversing on,
with the following properties:

@value - The value of the Edge
@to - The Node that the Edge is pointing to

Note that there is no field for the Node that
the edge is coming out of, because that is given
in the Node indicated ^.
--------------------------------------
*/
sig Edge {
    value: one Int,
    to: one Node
}

/*
--------------------------------------
Agent:
"Agent" is used to represent a pointer that
points to its current location. Its goal is to
go from its start to its destination.

@position - The current position the Agent is pointing to
@start - The starting node of the Agent
@dest - The ending node of the Agent
--------------------------------------
*/
sig Agent {
    var position: one Node,
    start: one Node,
    dest: one Node
}