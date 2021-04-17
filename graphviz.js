d3.select(svg).selectAll("*").remove();


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
//     var starting = 
//     var ending = 
//     console.log(edges);
//     console.log(edgeTo);
//     console.log(nodes);
//      console.log(nodeTo);
//     console.log(Node.edges);
//     console.log(nodeToEdgeToNode);
    //console.log(.edges.tuples().map(tuples => tuple.atoms()));

    var nodeToEdgeMap = new Map();
    var atoms = Node.atoms(true);
    atoms.forEach((node) => {
      const outEdge = node.edges.tuples().map(tuple => tuple.atoms());
      outEdge.map((info) => {
        
        let edgeName = info[0].toString()
        
        nodeToEdgeMap.set(node.tuples().map(f=>f.toString())[0], edgeName)
        
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

    
      
      
//       console.log(nodeToEdgeMap.keys())
//       console.log(edgeToNodeMap)

    for (let node of nodeToEdgeMap.keys()) {
        console.log(node)
        dataset.links.push({source: node, target: edgeToNodeMap.get(nodeToEdgeMap.get(node))} )
    }

//     console.log(dataset)



    for (var i = 0; i < nodes.length; i++) {
      color = "lightgrey"
      agent = ""
      
      for (var j = 0; j < position.length; j++){
        if (nodes[i] === position[j]){
          color = "skyblue"
          agent = agents[j]
        }
      }
      
      dataset.nodes.push({id: nodes[i], color: color, agent: agent });

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
        .attr("fill", function (d) { return d.color; })
        .attr("r", 20)
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
        .attr("dx", "0.4em")
        .style("text-anchor", "middle")
        .style("font-size", "10px")
        .text(d => d.id);
    const text2 = text.append("text")
        .attr("fill", "block")
        .attr("dx", "-3em")
        .style("font-weight", "bold")
        .style("text-anchor", "middle")
        .text(d => d.agent);


              
    var simulation = d3.forceSimulation(dataset.nodes)
    .force('charge', d3.forceManyBody())
    .force('center', d3.forceCenter(width / 2, height / 2))
    .force("link", d3.forceLink(dataset.links).id(function(d){return d.id}).distance(200))
    .on('tick', ticked);

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
    function dragstarted(d) {
      //if (!d3.event.active) simulation.alphaTarget(0.3).restart();//sets the current target alpha to the specified number in the range [0,1].
      d.fy = d.y; //fx - the node’s fixed x-position. Original is null.
      d.fx = d.x; //fy - the node’s fixed y-position. Original is null.
    }

    //When the drag gesture starts, the targeted node is fixed to the pointer
  function dragged(d) {
    console.log(d3.event)
    d.fx = d3.event.dx;
    d.fy = d3.event.dy;
  }

    //the targeted node is released when the gesture ends
    function dragended(d) {
      //if (!d3.event.active) simulation.alphaTarget(0);
      d.fx = null;
      d.fy = null;
      
      console.log("dataset after dragged is ...",dataset);
    }


