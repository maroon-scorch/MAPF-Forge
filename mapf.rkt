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
    -- edges: set Node->Int
    edges: set Edge
    -- perhaps have a set of colors->edges to support colored edges for a colored traversal 
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
@stops - keeps track of the nodes the Agent has traveled
@cumulative-weight - keeps track of the weight of the path
--------------------------------------
*/
sig Agent {
    var position: one Node,
    start: one Node,
    dest: one Node, -- For Traveling Salesman, Consider Changing this into set Node?
    var stops: set Node,
    cumulativeWeight: one Int
}

abstract sig Counter {
     var count: one Int
}

one sig stepCount extends Counter {}

pred isConnected {
    -- For Undirected Graphs

    -- The Graph is connected if there exists some node 
    -- such that all other nodes are reachable from it:
    some reachNode : Node | Node = reachNode + reachNode.^(edges.to)
}

example icTest1 is { isConnected } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3 + Atom4
    Edge = Edge01 + Edge12 + Edge13 + Edge34
    edges = Atom0->Edge01 + Atom1->Edge12 + Atom1->Edge13 + Atom3->Edge34
    to = Edge01->Atom1 + Edge12->Atom2 + Edge13->Atom3 + Edge34->Atom4
}

example icTest2 is { not isConnected } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3 + Atom4
    Edge = Edge01 + Edge12 + Edge34
    edges = Atom0->Edge01 + Atom1->Edge12 + Atom3->Edge34
    to = Edge01->Atom1 + Edge12->Atom2 + Edge34->Atom4
}

pred preConditions {
    isConnected
    #Node >= #Agent -- this line will probably spawn disasters
    dest.~dest in iden -- Agents shouldn't have the same destination
}


/*---------------*\
| Agent Operation |
\*---------------*/
pred init {
    -- Defines the initial state of the Position.
    -- No Agent Should Be Spawned together in the same place
    position.~position in iden
}

fun getNeighbors[loc: Node]: set Node {
    -- Returns the neighbors of the current node
    loc.edges.to
}

pred move[ag: Agent] {
    -- The Agent Chooses an unoccupied node and traverses to it.
    -- If there are vacant places to move to:
    let neighbors = getNeighbors[ag.position] |  {
        let openNode = neighbors - Agent.position | {
        -- Guard: there's an unoccupied place where the agent can move to
        some neighbors - Agent.position
        -- The next position should be in an unoccupied Place
        ag.position' in openNode
        -- Specify that only one agent can occupy this place
        after one ~position.ag
        -- Add the new location into the stops
        ag.stops' = ag.stops + ag.position'
        }
    }
}

pred wait[ag: Agent] {
    -- The Agent waits for the turn.
    ag.position' = ag.position
    ag.stops' = ag.stops
}

pred stop[ag: Agent] {
    -- The Agent has found its destination and stopped.
    -- Guard: The Agent has reached its destination
    ag.position = ag.dest
    ag.position' = ag.position
    ag.stops' = ag.stops
}

pred traces {
    preConditions
	init
	-- Something is always happening
    always {all agt: Agent | move[agt] or wait[agt] or stop[agt]}
}



-- "Sanity checking":
test expect {
  -- Unsat Traces makes test vacuously true
  vacuityTest: {traces} is sat

  -- Can each State be Reached by Traces
  canMove: {traces and (some agt: Agent | eventually (move[agt]))} is sat
  canWait: {traces and (some agt: Agent | eventually (wait[agt]))} is sat
  canStop: {traces and (some agt: Agent | eventually (stop[agt]))} is sat

  hasSolution: {traces and (all agt: Agent | eventually (stop[agt]))} is sat
}

sig Path {
    pth: set PathElt
}

sig PathElt {
    loc: one Node,
    next: lone PathElt
}

pred pathSetup {
    PathElt in Path.pth
    no (next.^next & iden)
}

pred pathIsList[p: Path] {
    // Transition Should Be Connected
    all pElt : p.pth | {
        pElt.next.loc != pElt.loc
        pElt.next.loc in getNeighbors[pElt.loc]
    }

    some start : p.pth | {
        p.pth in start + start.^next
    }
    -- no (edges.^edges & iden)
    -- *(next + ~next) = *(State->State)
}


example validPath is { pathSetup and pathIsList[Path] } for {
    -- Setup Structure
    Node = Node0 + Node1 + Node2 + Node3 + Node4
    Edge = Edge01 + Edge12 + Edge13 + Edge24
    edges = Node0->Edge01 + Node1->Edge12 + Node1->Edge13 + Node2->Edge24
    to = Edge01->Node1 + Edge12->Node2 + Edge13->Node3 + Edge24->Node4
    -- Path:
    Path = Path0
    PathElt = Pet1 + Pet2 --+ Pet3
    pth = Path0->Pet1 + Path0->Pet2 -- + Path0->Pet3
    next = Pet1->Pet2 -- + Pet2->Pet3
    loc = Pet1->Node0 + Pet2->Node1 -- + Pet3->Node4 
}

run {
    some Path
    pathSetup
    pathIsList[Path]
} for exactly 1 Path, exactly 3 PathElt

// test expect {
//        pathIsValid: { pathIsList[Path] } for validPath is sat
// }

//run { traces } for exactly 5 Node

/*---------------*\
|    Properties   |
\*---------------*/
pred wellFormed {
    -- The graph is "well-formed" for MAPF if for all agent 1, 2,
    -- there's a path from start of 1 to end of 1 that does not
    -- need to pass through the start of 2 and end of 2.
    {all agt1, agt2: Agent | {
        (agt1 != agt2) => {
            (agt1.position = agt1.dest) => {
            agt2.start not in agt1.stops
            agt2.dest not in agt1.stops
        }}
    }}
    -- does wellFormed => solution is always guaranteed
}

test expect {
    wellFormedImpliesSolution: {traces and wellFormed implies (all agt: Agent | eventually (stop[agt]))} is theorem
}

pred slidable {
    -- The graph is "slidable" if for all node 1, 2, 3, there exists
    -- a path from 1 to 3 without passing through 2.

    -- does slidable => solution is always guaranteed 
    -- (probably not, try limiting number of agents)
}

pred liveness {
    -- a trace is "live" if it never reaches a state where no agent can move
}

pred nsteps[num: Index] {
    -- a trace can be completed in n time intervals.
}

-- https://link.springer.com/chapter/10.1007/978-3-030-33274-7_6

-- Liveness - no deadlock -> could run into a livelock
-- Optimality issue
-- on track yayyyyy


// time step - NO SMT
// time step
// while (timestep < Threshold)
// we run for this many timesteps, 
// rozat - racket gives SMT + ability to synthesize programs with better structural

// Stepwise properties
// stepwise optimality???
// try to show invariants, etc.