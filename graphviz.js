d3.select(svg).selectAll("*").remove();


function hashCode(str) { // java String#hashCode
    var hash = 0;
    for (var i = 0; i < str.length; i++) {
       hash = str.charCodeAt(i) + ((hash << 5) - hash);
    }
    return hash;
} 

function intToRGB(i){
    var c = (i & 0x00FFFFFF)
        .toString(16)
        .toUpperCase();

    return "00000".substring(0, 6 - c.length) + c;
}

function agentToColor(i, d){
  return "#" + intToRGB(101 * (hashCode(i) + d))
}


svg = d3.select(svg)
    .append("g")
    .attr("width", 100)
    .attr("height", 100);

  
      //create dummy data
    const dataset =  {
      nodes: [

      ], 
      links: [

      ]
    };

    var edges = Edge.tuples().map(f => f.toString());
    var edgeTo = Edge.to.tuples().map(f => f.toString());
    var nodes = Node.tuples().map(f => f.toString());
    var nodeTo = Node.edges.tuples().map(f => f.toString());
    var nodeToEdgeToNode = Node.edges.to.tuples().map(f => f.toString());
    var position = Agent.position.tuples().map(f => f.toString());
    var agents = Agent.tuples().map(f => f.toString());
    var starting = Agent.start.tuples().map(f => f.toString());
    var ending = Agent.dest.tuples().map(f => f.toString());


//     for (var i = 0; i < agents.length; i++){    
//       svg.append("text")
//         .attr("x", 220)
//         .attr("y", 130 + i*30)
//         .text(agents[i] + " | start: " + starting[i] + " end: " + ending[i])
//         .style("font-size", "15px")
//         .attr("alignment-baseline","middle")

//     }

    var nodeToEdgeMap = new Map();
    var atoms = Node.atoms(true);
    
    atoms.forEach((node) => {
      const outEdge = node.edges.tuples().map(tuple => tuple.atoms());
      var nodeEdges = []
      outEdge.map((info) => {
        
        console.log(info)
        
        let edgeName = info[0].toString()
        nodeEdges.push(edgeName)
        //console.log(node)

        
        nodeToEdgeMap.set(node.tuples().map(f=>f.toString())[0], nodeEdges)
        
      });
      
    });

    var edgeToNodeMap = new Map();
    var destAtoms = Edge.atoms(true);
    destAtoms.forEach((edge) => {
      const destNode = edge.to.tuples().map(tuple => tuple.atoms());
      destNode.map((info) => {
        
        let destName = info[0].toString()
        
        edgeToNodeMap.set(edge.tuples().map(f=>f.toString())[0], destName)
        
      });
      
    });

    
      
      
      console.log(nodeToEdgeMap)
      console.log(edgeToNodeMap)

    for (let node of nodeToEdgeMap.keys()) {
        console.log(node)
        for (let edge of nodeToEdgeMap.get(node)){
          dataset.links.push({source: node, target: edgeToNodeMap.get(edge)} )  
        }
    }

//     console.log(dataset)



    for (var i = 0; i < nodes.length; i++) {
      color = "lightgrey"
      agent = ""
      outline = "lightgrey"
      
      for (var j = 0; j < position.length; j++){
        if (nodes[i] === position[j]){
          color = agentToColor(agents[j], j*298)
          agent = agents[j]
        }
        if (nodes[i] === ending[j]){
          outline = agentToColor(agents[j], j*298)
        }
      }
      
      dataset.nodes.push({id: nodes[i], color: color, agent: agent, outline: outline});

    }

    
    console.log("dataset is ...",dataset);

   svg.append("svg:defs").selectAll("marker")
    .data(["end"])      // Different link/path types can be defined here
  .enter().append("svg:marker")    // This section adds in the arrows
    .attr("id", String)
    .attr("viewBox", "0 -5 10 10")
    .attr("refX", 15)
    .attr("refY", -1.5)
    .attr("markerWidth", 2)
    .attr("markerHeight", 2)
    .attr("orient", "auto")
  .append("svg:path")
    .attr("d", "M0,-5L10,0L0,5");

     // Initialize the links
    const link = svg.append("g")
        .attr("class", "link")
        .selectAll("line")
        .data(dataset.links)
        .enter().append("line")
        .attr("fill", "black")
        .attr("stroke", "black")
        .attr('stroke-width', 2)
        .attr("marker-end", "url(#end)");

    // Initialize the nodes
    const node = svg.append("g")
        .attr("class", "nodes")
        .selectAll("circle")
        .data(dataset.nodes)
        .enter().append("circle")
        .attr("stroke", function(d){ return d.outline})
        .attr("stroke-width", 5)
        .attr("fill", function (d) { return d.color; })
        .attr("r", 30)
        .call(d3.drag()  //sets the event listener for the specified typenames and returns the drag behavior.
            .on("start", dragstarted) //start - after a new pointer becomes active (on mousedown or touchstart).
            .on("drag", dragged)      //drag - after an active pointer moves (on mousemove or touchmove).
            .on("end", dragended)     //end - after an active pointer becomes inactive (on mouseup, touchend or touchcancel).
         );

    // Text to nodes
    const text = svg.append("g")
        .attr("class", "text")
        .selectAll("text")
        .data(dataset.nodes)
        .enter();
    const text1 = text.append("text")
        .attr("fill", "block")
        .attr("dx", "0.3em")
        .style("text-anchor", "middle")
        .style("font-size", "17px")
        .text(d => d.id);
    const text2 = text.append("text")
        .attr("fill", "block")
        .attr("dx", "-4em")
        .style("font-weight", "bold")
        .style("text-anchor", "middle")
        .text(d => d.agent);



              
    var simulation = d3.forceSimulation(dataset.nodes)
    .force('charge', d3.forceManyBody())
    .force('center', d3.forceCenter(width / 2, height / 2))
    .force("link", d3.forceLink(dataset.links).distance(300).id(function(d){return d.id}))
    .on('tick', ticked);

    simulation.tick(120);

    node.attr("cx", function(d) { return d.x; })
      .attr("cy", function(d) { return d.y; })
    ticked()

    //Listen for tick events to render the nodes as they update in your Canvas or SVG.
    simulation.force('link').links(link);
    simulation.nodes(dataset.nodes).on("tick", ticked);
//         .nodes(dataset.nodes)//sets the simulation’s nodes to the specified array of objects, initializing their positions and velocities, and then re-initializes any bound forces;
//         .on("tick", ticked);//use simulation.on to listen for tick events as the simulation runs.
        // After this, Each node must be an object. The following properties are assigned by the simulation:
        // index - the node’s zero-based index into nodes
        // x - the node’s current x-position
        // y - the node’s current y-position
        // vx - the node’s current x-velocity
        // vy - the node’s current y-velocity

//     simulation
//         .links(dataset.links);//sets the array of links associated with this force, recomputes the distance and strength parameters for each link, and returns this force.
        // After this, Each link is an object with the following properties:
        // source - the link’s source node; 
        // target - the link’s target node; 
        // index - the zero-based index into links, assigned by this method


    // This function is run at each iteration of the force algorithm, updating the nodes position (the nodes data array is directly manipulated).
    function ticked() {
      link.attr("x1", d => d.source.x)
          .attr("y1", d => d.source.y)
          .attr("x2", d => d.target.x)
          .attr("y2", d => d.target.y);

      node.attr("cx", d => d.x)
          .attr("cy", d => d.y);

      text1.attr("x", d => d.x - 5) //position of the lower left point of the text
          .attr("y", d => d.y + 5); //position of the lower left point of the text
      text2.attr("x", d => d.x - 5) //position of the lower left point of the text
          .attr("y", d => d.y + 5); //position of the lower left point of the text
    }

    //When the drag gesture starts, the targeted node is fixed to the pointer
    //The simulation is temporarily “heated” during interaction by setting the target alpha to a non-zero value.
    function dragstarted(event, d) {
      if (!event.active) simulation.alphaTarget(0.01).restart();//sets the current target alpha to the specified number in the range [0,1].
      d.fy = d.y; //fx - the node’s fixed x-position. Original is null.
      d.fx = d.x; //fy - the node’s fixed y-position. Original is null.
    }

    //When the drag gesture starts, the targeted node is fixed to the pointer
  function dragged(event, d) {
//     console.log(d.x)
    d.fx = event.x;
    d.fy = event.y;
  }

    //the targeted node is released when the gesture ends
    function dragended(event, d) {
      if (!event.active) simulation.alphaTarget(0);
      d.fx = null;
      d.fy = null;
      
      console.log("dataset after dragged is ...",dataset);
    }


