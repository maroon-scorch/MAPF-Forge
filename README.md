# cs0170-spring-2021-multiagent-pathfinding
## Multi-Agent Pathfinding:

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
6 3
NodeA Node0 Node1
      1 2
NodeB Node0
      1
NodeC Node0
      1
Node0 Node1
      1
Node1 Node2
      1
Node2 Node1
      1
AgentA NodeA Node0
AgentB NodeB Node1
AgentC NodeC Node2
```
