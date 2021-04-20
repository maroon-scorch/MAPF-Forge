# cs0170-spring-2021-multiagent-pathfinding
[comment]: <> (This is a mark down file, and is intended to be read that way!)
## Multi-Agent Pathfinding (MAPF):
## Introduction:
Multi-Agent Pathfinding is a novel concept generated during the cusp of deep reinforcement learning. While having multiple agents navigating on the same graph is novel enough in its potentials for parallelization, the true novelty of Multi-agent Pathfinding comes in its key restriction - that agents following the paths may not collide with one another. With that seemingly tiny change, Multi-Agent Pathfinding has arisen with major applications in topics such as <b>factory robotics, simulated interactive modelings in video games, and more, etc</b>.
<br /><br />
Solving a pathfinding problem is rather trivial when number of agent is only one, it is quite literally just a reachability problem. However, the question gets increasingly complicated when multiple agents and conditions are involved. In addition to having to handle multiple agents, the requirement vary so that no Agents will follow each other, none will collide, etc. While the area is new, there has been some proposed solutions to resolve the issue. However, what's more surprising is that there are constraint based solvers that could resolve these MAPF problems without needing to figure out how to solve the problem directly (1). The reason why this is useful is because many SAT solvers are optimized enough so that they could retrieve the answers in a time that fares well relative to even other methods (1).
<br /><br />
In our project, we modeled the process of Multiagent Pathfinding in Forge and <b>implemented a MAPF Solver</b> that produces a solution (if it exists) to the MAPF problem with the shortest time steps. In addition, we have also explored some properties that will be verified in our Forge file.

## Design Questions:
- What tradeoffs did you make in choosing your representation? What else did you try that didn’t work as well?
    - The biggest decision we made was to have agents all move in parallel instead of one at a time. This complicated our node collision predicate, but allows our model to better represent a wider range of topics
    - Another smaller decision was to have sigs for the edges, instead of just relations on nodes. This allows for edges to contain information that affects the pathfinding much more easily. This allows the model to be easily changed to model a variety of problems
- What assumptions did you make about scope? What are the limits of your model?
    - We assumed that multi agent pathfinding was well defined, but it turns out there are quite a large amount of subtleties that can be considered when determining collisions, each of which drastically changes the scope of the project. For our project, we chose two collision conditions: agents cant occupy the same node, and agents can't swap nodes along the same edge (Node conflict and Edge conflicts). 
- Did your goals change at all from your proposal? Did you realize anything you planned was unrealistic, or that anything you thought was unrealistic was doable?
    - We determined that forge was not especially well suited to modeling modeling optimality problems. However using forge core allowed us to determine a temporally optimal path for the agents, but we were not able to determine a spatially optimal path. Due to this nuance, the goal that we orignally proposed was slightly altered. We still achieved multi-agent pathfinding, but not necessarily in the way we had envisioned. 
- How should we understand an instance of your model and what your custom visualization shows?
    - Instances are a collection of Nodes, Edges, and Agents. Agents point to the nodes they are currently "on" (indicated by their position relation). The sterling graph is pretty unintelligible, so we created a much more readable graph in our visualization. Each agents hasa color, and the node that the agent is on is colored in that color. Each agents destination node is outlined in the agent's color. 
![alt text](image/graphic.png "Title")
## Files:
### example
This is the folder that houses example input files that our MAPF Solver would take.
### collaborators
The list of collaborators we have for our Final Project.
### graphviz.js
The Visualizer of Our Project
### input.txt
A complicated example we will show during our Demo!
### mapf.rkt
The core Forge File we have that models the MAPF Problem and verifies properties of them.
### mapf_solver.rkt:
The MAPF Solver built on the basis of mapf.rkt
### parse-file.rkt
Converts the text file to Forge Instances

## How to Run Solver:
To run the solver:
```
racket mapf_solver.rkt <path_to_file>
```
The solver takes in a text file of the following input specification:
- The first line of the file should contain two numbers separated by a space, the first being the number of nodes, and the second being the number of Agents
- For each Node, they are represented as:
```
<Name of Node> <...Neighbor of Node, each separated by a space>
       <...Weight of the Edge to each respective Node above, each separated by a space>
```
- For each Agent, they are represented as:
```
<Name of Agent> <Starting Node of Agent> <Destination Node of Agent>
```
An example file looks like:
```
4 2
Node0 Node3 Node1
      1 2
Node1 Node2
      1
Node2 Node1
      1
Node3 Node1
      1
AgentA Node0 Node3
AgentB Node1 Node2
```
### Note:
To make a Node with zero edges extending out, you need to leave a blank line afterwards, so, ex:
```
NodeEmpty

```
Would be a valid line.
All Nodes with blank lines should also be the last Nodes in the file specified. For more, see example/blank-line.txt.

## Important Notice:
Thomas, who offered to help us figure out integrating our Forge files to forge/core, aided us in letting us write mapf_solver.rkt while providing support as a TA. The I/O parsing of text files (parse-file.rkt) to forge instances was directly provided by Thomas who believed that racket macro was too cumbersome and irrelevant to what we are doing to make us learn. Thank you Thomas!
## References:
[( 1. )](https://arxiv.org/ftp/arxiv/papers/1610/1610.05452.pdf) Makespan Optimal Solving of Cooperative Path-Finding via Reductions to Propositional Satisfiability by Pavel Surynek.
