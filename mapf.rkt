#lang forge

option problem_type temporal
option max_tracelength 20

/*---------------*\
|   Definitions   |
\*---------------*/

/*
--------------------------------------
Final Project - Multi-Agent Pathfinding
--------------------------------------
*/

/*
--------------------------------------
Node:
"Node" is used to represent a stop on a Graph
by which the Agent would be operating on

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
to another, by which the Agent would be traversing on

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

pred isConnected {
    -- The Graph is connected if there exists some node 
    -- such that all other nodes are reachable from it:
    some reachNode : Node | Node = reachNode + reachNode.^(edges.to)
}

pred preConditions {
    isConnected
    #Node >= #Agent -- this line will probably spawn disasters
}

run { isConnected } for exactly 5 Node

/*---------------*\
| Agent Operation |
\*---------------*/
pred init {

}



/*---------------*\
|    Properties   |
\*---------------*/
pred wellFormed {
    -- The graph is "well-formed" for MAPF if for all agent 1, 2,
    -- there's a path from start of 1 to end of 1 that does not
    -- need to pass through the start of 2 and end of 2.

    -- does wellFormed => solution is always guaranteed
}

pred slidable {
    -- The graph is "slidable" if for all node 1, 2, 3, there exists
    -- a path from 1 to 3 without passing through 2.

    -- does slidable => solution is always guaranteed 
    -- (probably not, try limiting number of agents)
}

-- https://link.springer.com/chapter/10.1007/978-3-030-33274-7_6