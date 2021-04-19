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
    var cumulativeWeight: one Int
}

//Checks if end is reachable from start
--used to make sure dest is reachable from start in agent pathfinding
pred reachable[start: Node, end: Node] {
    end in start + start.^(edges.to)
}
//TODO::Test cases for reachable ~5 tests
pred reachableTestpred {
    all agt: Agent | reachable [agt.start, agt.dest]
}
example reachableEnds is { reachableTestpred } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3
    Edge = Edge01 + Edge12 + Edge23
    edges = Atom0->Edge01 + Atom1->Edge12 + Atom2->Edge23
    to = Edge01->Atom1 + Edge12->Atom2 + Edge23->Atom3
    Agent = Agent0
    start = Agent0->Atom0
    dest = Agent0->Atom3
}

example reachableNextNode is { reachableTestpred } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3
    Edge = Edge01 + Edge12 + Edge23
    edges = Atom0->Edge01 + Atom1->Edge12 + Atom2->Edge23
    to = Edge01->Atom1 + Edge12->Atom2 + Edge23->Atom3
    Agent = Agent0
    start = Agent0->Atom0
    dest = Agent0->Atom1
}

example reachableSecondNode is { reachableTestpred } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3
    Edge = Edge01 + Edge12 + Edge23
    edges = Atom0->Edge01 + Atom1->Edge12 + Atom2->Edge23
    to = Edge01->Atom1 + Edge12->Atom2 + Edge23->Atom3
    Agent = Agent0
    start = Agent0->Atom1
    dest = Agent0->Atom3
}

example reachableDisconnected is { not reachableTestpred } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3 + Atom4
    Edge = Edge01 + Edge12 + Edge23
    edges = Atom0->Edge01 + Atom1->Edge12 + Atom2->Edge23
    to = Edge01->Atom1 + Edge12->Atom2 + Edge23->Atom3
    Agent = Agent0
    start = Agent0->Atom1
    dest = Agent0->Atom4
}

example reachableBackwardsDirectional is { not reachableTestpred } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3
    Edge = Edge01 + Edge12 + Edge23
    edges = Atom0->Edge01 + Atom1->Edge12 + Atom2->Edge23
    to = Edge01->Atom1 + Edge12->Atom2 + Edge23->Atom3
    Agent = Agent0
    start = Agent0->Atom3
    dest = Agent0->Atom0
}

example reachableBackwardsUndirectional is { reachableTestpred } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3
    Edge = Edge01 + Edge10 + Edge12 + Edge21 + Edge23 + Edge32
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom1->Edge12 + Atom2->Edge21 + Atom2->Edge23 + Atom3->Edge32
    to = Edge01->Atom1 + Edge10->Atom0 + Edge12->Atom2 + Edge21->Atom1 + Edge23->Atom3 + Edge32->Atom2
    Agent = Agent0
    start = Agent0->Atom3
    dest = Agent0->Atom0
}

example reachableSelfEdge is { reachableTestpred } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3
    Edge = Edge01 + Edge10 + Edge12 + Edge21 + Edge23 + Edge33
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom1->Edge12 + Atom2->Edge21 + Atom2->Edge23 + Atom3->Edge33
    to = Edge01->Atom1 + Edge10->Atom0 + Edge12->Atom2 + Edge21->Atom1 + Edge23->Atom3 + Edge33->Atom3
    Agent = Agent0
    start = Agent0->Atom3
    dest = Agent0->Atom3
}

//Determines the static parts of our properties before the initial state;
//Makes sure each agent can reach its destination from its start
pred preConditions {
    all agt : Agent | reachable[agt.start, agt.dest]
    start.~start in iden -- Agents shouldn't have the same start
    dest.~dest in iden -- Agents shouldn't have the same destination
}
//TODO::Test cases for preConditions
example reachabilityAll is { preConditions } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3
    Edge = Edge01 + Edge10 + Edge12 + Edge21 + Edge23 + Edge33
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom1->Edge12 + Atom2->Edge21 + Atom2->Edge23 + Atom3->Edge33
    to = Edge01->Atom1 + Edge10->Atom0 + Edge12->Atom2 + Edge21->Atom1 + Edge23->Atom3 + Edge33->Atom3
    Agent = Agent0 + Agent1 + Agent2
    start = Agent0->Atom3 + Agent1->Atom1 + Agent2->Atom2
    dest = Agent0->Atom3 + Agent1->Atom2 + Agent2->Atom1
}

example reachabilityNone is { not preConditions } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3 + Atom4
    Edge = Edge01 + Edge12 + Edge23 + Edge34
    edges = Atom0->Edge01 + Atom1->Edge12 + Atom2->Edge23 + Atom3->Edge34
    to = Edge01->Atom1 + Edge12->Atom2 + Edge23->Atom3 + Edge34->Atom4
    Agent = Agent0 + Agent1 + Agent2
    start = Agent0->Atom4 + Agent1->Atom3 + Agent2->Atom2
    dest = Agent0->Atom3 + Agent1->Atom2 + Agent2->Atom1
}

example reachabilitySome is { not preConditions } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3 + Atom4
    Edge = Edge01 + Edge10 + Edge12 + Edge21 + Edge23 + Edge33
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom1->Edge12 + Atom2->Edge21 + Atom2->Edge23 + Atom3->Edge33
    to = Edge01->Atom1 + Edge10->Atom0 + Edge12->Atom2 + Edge21->Atom1 + Edge23->Atom3 + Edge33->Atom3
    Agent = Agent0 + Agent1 + Agent2
    start = Agent0->Atom0 + Agent1->Atom2 + Agent2->Atom3
    dest = Agent0->Atom3 + Agent1->Atom1 + Agent2->Atom4
}

example sameStart is { not preConditions } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3
    Edge = Edge01 + Edge10 + Edge12 + Edge21 + Edge23 + Edge33
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom1->Edge12 + Atom2->Edge21 + Atom2->Edge23 + Atom3->Edge33
    to = Edge01->Atom1 + Edge10->Atom0 + Edge12->Atom2 + Edge21->Atom1 + Edge23->Atom3 + Edge33->Atom3
    Agent = Agent0 + Agent1
    start = Agent0->Atom0 + Agent1->Atom0
    dest = Agent0->Atom3 + Agent1->Atom2
}

example sameStart is { not preConditions } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3
    Edge = Edge01 + Edge10 + Edge12 + Edge21 + Edge23 + Edge33
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom1->Edge12 + Atom2->Edge21 + Atom2->Edge23 + Atom3->Edge33
    to = Edge01->Atom1 + Edge10->Atom0 + Edge12->Atom2 + Edge21->Atom1 + Edge23->Atom3 + Edge33->Atom3
    Agent = Agent0 + Agent1
    start = Agent0->Atom0 + Agent1->Atom1
    dest = Agent0->Atom3 + Agent1->Atom3
}

/*---------------*\
| Agent Operation |
\*---------------*/
pred init {
    -- Defines the initial state of the Position.
    -- Agents Should Be Spawned At Their Start
    all agt : Agent | agt.position = agt.start
}
//TODO::Test cases for init
example initBasicTrue is { init } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3
    Edge = Edge01 + Edge10 + Edge12 + Edge21 + Edge23 + Edge33
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom1->Edge12 + Atom2->Edge21 + Atom2->Edge23 + Atom3->Edge33
    to = Edge01->Atom1 + Edge10->Atom0 + Edge12->Atom2 + Edge21->Atom1 + Edge23->Atom3 + Edge33->Atom3
    Agent = Agent0 + Agent1 + Agent2
    start = Agent0->Atom3 + Agent1->Atom1 + Agent2->Atom2
    dest = Agent0->Atom3 + Agent1->Atom2 + Agent2->Atom1
    position = Agent0->Atom3 + Agent1->Atom1 + Agent2->Atom2
}

example initBasicFalse is { not init } for {
    Node = Atom0 + Atom1 + Atom2 + Atom3
    Edge = Edge01 + Edge10 + Edge12 + Edge21 + Edge23 + Edge33
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom1->Edge12 + Atom2->Edge21 + Atom2->Edge23 + Atom3->Edge33
    to = Edge01->Atom1 + Edge10->Atom0 + Edge12->Atom2 + Edge21->Atom1 + Edge23->Atom3 + Edge33->Atom3
    Agent = Agent0 + Agent1 + Agent2
    start = Agent0->Atom3 + Agent1->Atom1 + Agent2->Atom2
    dest = Agent0->Atom3 + Agent1->Atom2 + Agent2->Atom1
    position = Agent0->Atom2 + Agent1->Atom3 + Agent2->Atom0
}

fun getNeighbors[loc: Node]: set Node {
    -- Returns the neighbors of the current node
    loc.edges.to
}
//TODO::Test cases for getNeighbors
// lone sig testNode extends Node {}

// example getNeighborsBasic is { #getNeighbors[testNode] = 3 } for {
//     Node = Atom0 + Atom1 + Atom2 + testNode
//     Edge = Edge01 + Edge10 + Edge12 + Edge21
//     edges = Atom0->Edge01 + Atom1->Edge10 + Atom1->Edge12 + Atom2->Edge21
//     to = Edge01->Atom1 + Edge10->Atom0 + Edge12->Atom2 + Edge21->Atom1
// }

// example getNeighborsZero is { #getNeighbors[testNode] = 0 } for {
//     Node = Atom0 + Atom1 + Atom2 + testNode
//     Edge = Edge01 + Edge10 + Edge12 + Edge21 + Edget1 + Edget2 + Edget3
//     edges = Atom0->Edge01 + Atom1->Edge10 + Atom1->Edge12 + Atom2->Edge21 + testNode->Edget0 + testNode->Edget1 + testNode->Edget2
//     to = Edge01->Atom1 + Edge10->Atom0 + Edge12->Atom2 + Edge21->Atom1 + Edget0->Atom0 + Edget1->Atom1 + Edget2->Atom2
// }


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
        after one (ag.position).(~position)
        -- Add the new location into the stops
        ag.stops' = ag.stops + ag.position'
        }
    }
}

pred wait[ag: Agent] {
    -- The Agent waits for the turn.
    -- Guard: Waiting at the destination is just stopping
    -- ag.position != ag.dest
    ag.position' = ag.position
    ag.stops' = ag.stops
}


--stop would be used when agent reaches destination, not sure if needed yet--

// pred stop[ag: Agent] {
//     -- The Agent has found its destination and stopped.
//     -- Guard: The Agent has reached its destination
//     ag.position = ag.dest
//     ag.position' = ag.position
//     ag.stops' = ag.stops
// }

--Current traces form that defines states of movement as all agents taking an action per state
pred traces {
    preConditions
	init
	-- Something is always happening
    always {all agt: Agent | move[agt] or wait[agt]}
}

pred tracesMove {
    preConditions
	init
	-- Something is always happening
    always {all agt: Agent | move[agt]}
}

pred tracesWait {
    preConditions
	init
	-- Something is always happening
    always {all agt: Agent | wait[agt]}
}

/*
--Other form of traces that defines states of movement as one agent taking an action per state
pred traces {
    preConditions
	init
    always { one moveAgt : Agent | {
        move[moveAgt]
        all restAgt : Agent - moveAgt | {
            wait[restAgt]
        }
    }}
    noCollision
   --  always {all agt: Agent | move[agt] or wait[agt] or stop[agt]}
}
*/

--solved is defined as all agents having reached their destinations
pred solved {
    all agt: Agent | eventually (agt.position = agt.dest)
}


-- "Sanity checking":
test expect {
  -- Unsat Traces makes test vacuously true
  vacuityTest: {traces} is sat

  -- Can each State be Reached by Traces
  canMove: {traces and (some agt: Agent | eventually (move[agt]))} is sat
  canWait: {traces and (some agt: Agent | eventually (wait[agt]))} is sat
  -- canStop: {traces and (some agt: Agent | eventually (stop[agt]))} is sat

  hasSolution: {traces and solved} is sat
}

// Simple Example for Solver
inst structure {
    Node = NodeA + NodeB + NodeC + Node0 + Node1 + Node2
    Edge = EdgeA0 + EdgeB0 + EdgeC0 + Edge01 + Edge02
    edges = NodeA->EdgeA0 + NodeB->EdgeB0 + NodeC->EdgeC0 +
    Node0->Edge01 + Node0->Edge02
    to = EdgeA0->Node0 + EdgeB0->Node0 + EdgeC0->Node0 +
    Edge01->Node1 + Edge02->Node2

    Agent = AgentA + AgentB + AgentC
    start = AgentA->NodeA + AgentB->NodeB + AgentC->NodeC
    dest = AgentA->Node0 + AgentB->Node1 + AgentC->Node2
}

// run { traces and solved } for {
//     structure
// }


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                Traces Test Instances
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
inst oneAgent {
    Node = Node0 + Node1 + Node2
    Edge = Edge01 + Edge12
    edges = Node0->Edge01 + Node1->Edge12
    to = Edge01->Node1 + Edge12->Node2

    Agent = Agent0
    start = Agent0->Node0
    dest = Agent0->Node2
}

inst collide {
    Node = Node0 + Node1
    Edge = Edge01 + Edge10
    edges = Node0->Edge01 + Node1->Edge10
    to = Edge01->Node1 + Edge10->Node0

    Agent = Agent0 + Agent1
    start = Agent0->Node0 + Agent1->Node1
    dest = Agent0->Node1 + Agent1->Node0
}

inst notCollide {
    Node = Node0 + Node1 + Node2
    Edge = Edge01 + Edge10 + Edge12 + Edge20
    edges = Node0->Edge01 + Node1->Edge10 + Node1->Edge12 + Node2->Edge20
    to = Edge01->Node1 + Edge10->Node0 + Edge12->Node2 + Edge20->Node0

    Agent = Agent0 + Agent1
    start = Agent0->Node0 + Agent1->Node1
    dest = Agent0->Node1 + Agent1->Node0
}

inst discreteMap {
    Node = Node0 + Node1 + Node2 + Node3
    Edge = Edge01 + Edge23
    edges = Node0->Edge01 + Node2->Edge23
    to = Edge01->Node1 + Edge23->Node3

    Agent = Agent0 + Agent1
    start = Agent0->Node0 + Agent1->Node2
    dest = Agent0->Node1 + Agent1->Node3
}

inst waitingExample {
    Node = NodeA + NodeB + NodeC + Node0 + Node1 + Node2
    Edge = EdgeA0 + EdgeB0 + EdgeC0 + Edge01 + Edge02
    edges = NodeA->EdgeA0 + NodeB->EdgeB0 + NodeC->EdgeC0 +
    Node0->Edge01 + Node0->Edge02
    to = EdgeA0->Node0 + EdgeB0->Node0 + EdgeC0->Node0 +
    Edge01->Node1 + Edge02->Node2

    Agent = AgentA + AgentB + AgentC
    start = AgentA->NodeA + AgentB->NodeB + AgentC->NodeC
    dest = AgentA->Node0 + AgentB->Node1 + AgentC->Node2
}

inst collideExample2 {
    Node = Node1 + Node2 + Node3
    Edge = Edge12 + Edge21 + Edge23 + Edge32
    edges = Node1->Edge12 + Node2->Edge21 + Node2->Edge23 + Node3->Edge32
    to = Edge12->Node2 + Edge21->Node1 + Edge23->Node3 + Edge32->Node2

    Agent = AgentA + AgentB
    start = AgentA->Node2 + AgentB->Node3
    dest = AgentA->Node3 + AgentB->Node1
}

inst multiEdge {
    Node = Node1 + Node2 + Node3 + Node4
    Edge = Edge12 + Edge13 + Edge14
    edges = Node1->Edge12 + Node1->Edge13 + Node1->Edge14
    to = Edge12->Node2 + Edge13->Node3 + Edge14->Node4

    Agent = AgentA
    start = AgentA->Node1
    dest = AgentA->Node4
}

inst multiAgent {
    Node = NodeA + NodeB + NodeC + Node0 + Node1
    Edge = EdgeA0 + EdgeB0 + EdgeC0 + Edge01
    edges = NodeA->EdgeA0 + NodeB->EdgeB0 + NodeC->EdgeC0 +
    Node0->Edge01
    to = EdgeA0->Node0 + EdgeB0->Node0 + EdgeC0->Node0 +
    Edge01->Node1

    Agent = AgentA + AgentB
    start = AgentA->NodeA + AgentB->NodeB
    dest = AgentA->Node0 + AgentB->Node1
}

inst allMove {
    Node = Atom0 + Atom1 + Atom2 + Atom3 + Atom4 + Atom5 + Atom6
    Edge = Edge01 + Edge10 + Edge02 + Edge20 + Edge13 + Edge31 + Edge14 + Edge41 + Edge25 + Edge52 + Edge26 + Edge62 +
           Edge34 + Edge43 + Edge56 + Edge65
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom0->Edge02 + Atom2->Edge20 + Atom1->Edge13 + Atom3->Edge31 + Atom1->Edge14 +
            Atom4->Edge41 + Atom2->Edge25 + Atom5->Edge52 + Atom2->Edge26 + Atom6->Edge62 + Atom3->Edge34 + Atom4->Edge43 +
            Atom5->Edge56 + Atom6->Edge65
    to = Edge01->Atom1 + Edge10->Atom0 + Edge02->Atom2 + Edge20->Atom0 + Edge13->Atom3 + Edge31->Atom1 + Edge14->Atom4 +
         Edge41->Atom1 + Edge25->Atom5 + Edge52->Atom2 + Edge26->Atom6 + Edge62->Atom2 + Edge34->Atom4 + Edge43->Atom3 +
         Edge56->Atom6 + Edge65->Atom6
    Agent = Agent0 + Agent1 + Agent2
    start = Agent0->Atom0 + Agent1->Atom3 + Agent2->Atom2
    dest = Agent0->Atom3 + Agent1->Atom4 + Agent2->Atom5
}

inst tailGate {
    Node = Atom0 + Atom1 + Atom2 + Atom3 + Atom4 + Atom5 + Atom6
    Edge = Edge01 + Edge10 + Edge02 + Edge20 + Edge13 + Edge31 + Edge14 + Edge41 + Edge25 + Edge52 + Edge26 + Edge62
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom0->Edge02 + Atom2->Edge20 + Atom1->Edge13 + Atom3->Edge31 + Atom1->Edge14 +
            Atom4->Edge41 + Atom2->Edge25 + Atom5->Edge52 + Atom2->Edge26 + Atom6->Edge62
    to = Edge01->Atom1 + Edge10->Atom0 + Edge02->Atom2 + Edge20->Atom0 + Edge13->Atom3 + Edge31->Atom1 + Edge14->Atom4 +
         Edge41->Atom1 + Edge25->Atom5 + Edge52->Atom2 + Edge26->Atom6 + Edge62->Atom2
    Agent = Agent0 + Agent1 + Agent2
    start = Agent0->Atom0 + Agent1->Atom1 + Agent2->Atom2
    dest = Agent0->Atom3 + Agent1->Atom4 + Agent2->Atom5
}

inst collision {
    Node = Atom0 + Atom1 + Atom2 + Atom3 + Atom4 + Atom5 + Atom6
    Edge = Edge01 + Edge10 + Edge02 + Edge20 + Edge13 + Edge31 + Edge14 + Edge41 + Edge25 + Edge52 + Edge26 + Edge62
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom0->Edge02 + Atom2->Edge20 + Atom1->Edge13 + Atom3->Edge31 + Atom1->Edge14 +
            Atom4->Edge41 + Atom2->Edge25 + Atom5->Edge52 + Atom2->Edge26 + Atom6->Edge62
    to = Edge01->Atom1 + Edge10->Atom0 + Edge02->Atom2 + Edge20->Atom0 + Edge13->Atom3 + Edge31->Atom1 + Edge14->Atom4 +
         Edge41->Atom1 + Edge25->Atom5 + Edge52->Atom2 + Edge26->Atom6 + Edge62->Atom2
    Agent = Agent0 + Agent1 + Agent2
    start = Agent0->Atom0 + Agent1->Atom1 + Agent2->Atom2
    dest = Agent0->Atom3 + Agent1->Atom0 + Agent2->Atom5
}

inst meetUp {
    Node = Atom0 + Atom1 + Atom2 + Atom3 + Atom4 + Atom5 + Atom6
    Edge = Edge01 + Edge10 + Edge02 + Edge20 + Edge13 + Edge31 + Edge14 + Edge41 + Edge25 + Edge52 + Edge26 + Edge62
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom0->Edge02 + Atom2->Edge20 + Atom1->Edge13 + Atom3->Edge31 + Atom1->Edge14 +
            Atom4->Edge41 + Atom2->Edge25 + Atom5->Edge52 + Atom2->Edge26 + Atom6->Edge62
    to = Edge01->Atom1 + Edge10->Atom0 + Edge02->Atom2 + Edge20->Atom0 + Edge13->Atom3 + Edge31->Atom1 + Edge14->Atom4 +
         Edge41->Atom1 + Edge25->Atom5 + Edge52->Atom2 + Edge26->Atom6 + Edge62->Atom2
    Agent = Agent0 + Agent1 + Agent2
    start = Agent0->Atom3 + Agent1->Atom4 + Agent2->Atom2
    dest = Agent0->Atom0 + Agent1->Atom1 + Agent2->Atom5
}

inst mexicanStandOff {
    Node = Atom0 + Atom1 + Atom2
    Edge = Edge01 + Edge10 + Edge20 + Edge02 + Edge21 + Edge12
    edges = Atom0->Edge01 + Atom1->Edge10 + Atom0->Edge02 + Atom2->Edge20 + Atom2->Edge21 + Atom1->Edge12
    to =    Edge01->Atom1 + Edge10->Atom0 + Edge02->Atom2 + Edge20->Atom0 + Edge21->Atom1 + Edge12->Atom2
    Agent = Agent0 + Agent1 + Agent2
    start = Agent0->Atom0 + Agent1->Atom1 + Agent2->Atom2
    dest = Agent0->Atom1 + Agent1->Atom2 + Agent2->Atom0
}

test expect {
    oneAgentTest: { traces and solved } for oneAgent is sat
    collideTest: { traces and solved } for collide is unsat
    collideTest2: { traces and solved } for collideExample2 is unsat
    notCollideTest: { traces and solved } for notCollide is sat
    discreteMapTest: { traces and solved } for discreteMap is sat
    waitingExampleTest: { traces and solved } for waitingExample is sat
    allMovetest: {tracesMove} for allMove is sat
    tailGatetest: {tracesMove} for tailGate is unsat
    collisiontest: {tracesMove} for collision is unsat
    meetUptest: {tracesMove} for meetUp is unsat
    allMovesolvetest: {traces and solved} for allMove is sat
    tailGatesolvetest: {traces and solved} for tailGate is sat
    collisionsolvetest: {traces and solved} for collision is sat
    meetUpsolvetest: {traces and solved} for meetUp is sat
    mexicanStandOffsolveTest: {traces and solved} for mexicanStandOff is unsat
    mexicanStandOffwaitTest: {tracesWait} for mexicanStandOff is sat
}


// Simple Example for Solver
inst structur {
    Node = NodeA + NodeB + NodeC + Node0 + Node1 + Node2
    Edge = EdgeA0 + EdgeB0 + EdgeC0 + Edge01 + Edge02
    edges = NodeA->EdgeA0 + NodeB->EdgeB0 + NodeC->EdgeC0 +
    Node0->Edge01 + Node0->Edge02
    to = EdgeA0->Node0 + EdgeB0->Node0 + EdgeC0->Node0 +
    Edge01->Node1 + Edge02->Node2

    Agent = AgentA + AgentB + AgentC
    start = AgentA->NodeA + AgentB->NodeB + AgentC->NodeC
    dest = AgentA->Node0 + AgentB->Node1 + AgentC->Node2
}

// run { traces and solved } for structur

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        Property Verification
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
sig Path {
    pth: set PathElt
}

sig PathElt {
    loc: one Node,
    next: lone PathElt
}

//Makes sure that each PathElt in a Path form a list
pred pathSetup {
    PathElt in Path.pth
    no (next.^next & iden)
    // Next Should Only Have One Unique Parent Each
    next.~next in iden
}



//Makes sure that each PathElt in a Path is pointing to a directly connected Node from itself
pred pathIsList[p: Path] {
    // Transition Should Be Connected
    all pElt : p.pth | {
        pElt.next.loc != pElt.loc
        pElt.next.loc in getNeighbors[pElt.loc]
    }

    some start : p.pth | {
        p.pth in start + start.^next
    }
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

inst looper {
    -- Setup Structure
    Node = Node0 + Node1 + Node2 + Node3
    Edge = Edge01 + Edge12 + Edge23 + Edge31
    edges = Node0->Edge01 + Node1->Edge12 + Node2->Edge23 + Node3->Edge31
    to =    Edge01->Node1 + Edge12->Node2 + Edge23->Node3 + Edge31->Node1
    -- Path:
    Path = Path0
    PathElt = Pet1 + Pet2 + Pet3 + Pet4
    pth = Path0->Pet1 + Path0->Pet2 + Path0->Pet3 + Path0->Pet4
    next = Pet1->Pet2 + Pet2->Pet3 + Pet3->Pet4
    loc = Pet1->Node1 + Pet2->Node2 + Pet3->Node3 
}
test expect {
    loopPath: { pathSetup } for looper is unsat
    loopPath2: { pathSetup and pathIsList[Path] } for looper is unsat
}
/*---------------*\
|    Properties   |
\*---------------*/
// Invariant Checking:
pred noCollision {
    -- Assures that no two agents never collide 
    always {
        all agt1, agt2 : Agent | {
            agt1 != agt2 => {
                -- No Agent Occupies the Same Spot
                agt1.position != agt2.position
                -- No Agent Swaps Position during the Process (they collide on the edge)
                not (agt1.position' = agt2.position and agt2.position' = agt1.position)
            }
        }
    }
}

// Safety Checking - No Collision has occurred during the process
test expect {
    solvedStateHasNoCollision: { traces and solved implies noCollision } is theorem
}

pred jumping {
    -- The Agent Skips a Node and "Jumps"
    eventually { 
        some agt: Agent | {
            after {agt.position} not in agt.position + getNeighbors[agt.position]
        }
    }
}

// Invariant - The Agents always trace the graph
test expect {
    tracesDoesNotJump: { traces and jumping } is unsat
    solvedStateDoesNotJump: { traces and solved and jumping } is unsat
}

pred wellFormed {
    -- The graph is "well-formed" for MAPF if for all agent 1, 2,
    -- there's a path from start of 1 to end of 1 that does not
    -- need to pass through the start of 2 and end of 2.
    
    pathSetup
    all agt1, agt2: Agent | {
        (agt1 != agt2) => { some connectPath : Path | {
            pathIsList[connectPath]
            agt1.start + agt1.dest in connectPath.pth.loc
            agt2.start + agt2.dest not in connectPath.pth.loc
        }}
    }

    -- does wellFormed => solution is always guaranteed
}

//TODO::Create new more wellFormed specific instances/tests
test expect {
    wellFormedPositive: { wellFormed } for discreteMap is sat
    wellFormedNegative: { wellFormed } for waitingExample is unsat
    wfPathIncludeStartEnd: { wellFormed } for notCollide is unsat
    -- wellFormed implies { traces and solved is sat } is theorem
   --  { wellFormed and traces implies { some Solution } } for exactly one Solution is theorem
}

-- separate out the concern
-- Create a run in forge core that has wellformed, and just check if those are sat in wellformed and traces

/*
//Statically checks if a mapf is solvable
pred solvable[condition: set Agent] {
    ...
}
*/

//Traces but guarantees wellFormed
pred wellFormedTraces {
    traces
    wellFormed
}

/*
wellFormedTraces guarantees a solution, but how do you say that solved is sat?

test expect {
    wellFormedVacuityTest: { wellFormed } is sat
    wellFormedTest: { wellFormed and traces implies solved } is theorem
}
*/

/*-----------------------*\
|     Path Procedures     |
\*-----------------------*/

/*
// This is going to fail because the Agent has no incentives
// to go the destination, so it can just wait forever at the same spot.
check {
    traces implies solved
} for exactly one Agent
*/

test expect {
   tracesSometimesSolve: { traces implies solved } is sat
   tracesSometimesUnsolve: { not (traces implies solved) } is sat
}

//Method to naively force agents to take a path
pred naivePathFinder {
	traces
	always {
        all agt : Agent | {
            not wait[agt]
        }
	}
}

// test expect {
//     oneAgentAlwaysReachDest: {
//         traces implies solved
//     } for exactly one Agent is theorem
// }

-- Best Guess: using until constrains the shape of the graph to also be able to accomplish until
--wellformed

/// These two predicates are experimental. They currently basically say if a graph is solvable, then it is solvable. This makes wellformedness not really matter
/// Also these predicates force all agents to always move, which just isn't proper

pred nwfPathFinder {
	traces
	always {
        all agt : Agent | {
            move[agt] until agt.position = agt.dest
        }
	}
}

--not well formed
pred incentivePathFinder {
	wellFormedTraces
	always {
        all agt : Agent | {
            move[agt] until agt.position = agt.dest
        }
	}
}

// test expect {
//     {{ nwfPathFinder => solved } <=> { incentivePathFinder => solved }} is theorem
//     wellFormedSolution: { not (traces and solved) => not wellFormed  } is theorem
// }

// test expect {
//     { nwfPathFinder implies wellFormed } is theorem
// } 

pred slidable {
    -- The graph is "slidable" if for all node 1, 2, 3, there exists
    -- a path from 1 to 3 without passing through 2.
    pathSetup
    all node1, node2, node3: Node | {
        (node1 != node2 and node2 != node3 and node1 != node3) =>
        { some connectPath : Path | {
            pathIsList[connectPath]
            node1 + node2 in connectPath.pth.loc
            node3 not in connectPath.pth.loc
        }}
    }
    -- does slidable => solution is always guaranteed 
    -- (probably not, try limiting number of agents)
}

//deadlock: Can't move
//livelock: Trapped in a cycle but still moving
//If any agent ever doesn't reach its destination, that means that it encountered either a deadlock or livelock on its journey.
//Therefore a predicate constraining that agents reach their destination is constraining that agents don't encounter a lock

pred deadLocked {
    traces
    pathSetup
    all agt : Agent | {
        no connectedPath : Path | {
            pathIsList[connectedPath]
            all agt2: Agent - agt | {
                agt2.position not in connectedPath.pth.loc
            }
        }
    }       
}

pred liveLocked {
    traces
    not deadLocked
    always {
        some agt: Agent | agt.position != agt.dest
    }
}

-- if it's moving the whole time and could reach destination
-- deadlock can't reach destination
-- livelock can reach destination, but agent waits forever and never goes there

pred nsteps[num: Int] {
    -- a trace can be completed in n time intervals.
}

-- https://link.springer.com/chapter/10.1007/978-3-030-33274-7_6

--junk pile

/* 
--was going to be used to log how many steps it took to go from start to dest
abstract sig Counter {
      var count: one Int
}

one sig stepCount extends Counter {}
*/

/*

--these two predicates overconstrain our graphs, we moreso just want dest to be reachable from start
pred isConnected {
    -- For Undirected Graphs

    -- The Graph is connected if there exists some node 
    -- such that all other nodes are reachable from it:
    some reachNode : Node | Node = reachNode + reachNode.^(edges.to)
}


pred isUndirected {
    all n : Node | all neighbor : n.edges.to | {
        n in neighbor.edges.to
    }
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

*/

/*
/*
test expect {
    ipfImpliesNotWaiting: { incentivePathFinder implies always { all agt : Agent | {
            not wait[agt] until agt.position = agt.dest
        }}} is theorem
}
*/

/*
test expect {
    ipfVacuity: { incentivePathFinder } is sat
    nwfFindsPath: { nwfPathFinder implies solved } is theorem
    ipfFindsPath: { incentivePathFinder implies solved } is theorem
    -- ipfFindsPath2: { incentivePathFinder implies not solved } for exactly 2 Agent is sat
    -- ipfFindsPath3: { not (incentivePathFinder implies solved) } for exactly 2 Agent is sat
    -- ipfFindsPath4: { incentivePathFinder implies solved } for exactly 2 Agent is theorem
    -- ipfFindsPath5: { incentivePathFinder implies not solved } for exactly 2 Agent is theorem
}

test expect {
    ipfFindsPathHUHHHHH: { not (incentivePathFinder implies solved) } for exactly 2 Agent is theorem
}
*/

/*
run { 
    traces
    some Agent
    all agt : Agent | agt.start != agt.dest
}
*/