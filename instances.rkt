#lang forge

open "mapf.rkt"

pred deadLocked1 {
    traces
    pathSetup
    always { all agt : Agent | {
            all connectedPath : Path | {
                pathIsList[connectedPath]
                agt.start + agt.dest in connectedPath.pth.loc
                some agt2: Agent - agt | {
                    agt2.position in connectedPath.pth.loc
                }
            }
        }
    }
    -- all agt: Agent | agt.start != agt.dest
    some Agent
    -- some Path
    --always { some agt: Agent | agt.position != agt.dest}
}





pred isNotConnected[nodeSet : Node, pos : Node, destination : Node] {
    let edgesAvailable = Edge - (nodeSet.edges + nodeSet.~to) | {
        destination not in pos + pos.^((Node->edgesAvailable & edges).(edgesAvailable->Node & to))
    }
}


pred isBlocked[agt : Agent] {
    let blockAgts = Agent - agt | {
        some blockAgts
        isNotConnected[Node - blockAgts, agt.position, agt.dest]
    }
}

pred deadLocked2 {
    traces
    -- The state can't be deadlocked if there's no agent
    some Agent
    eventually { always { all agt : Agent | {
        isBlocked[agt]
    }}}
}



test expect {
    { deadLocked1 } is sat
    { deadLocked2 } is sat
}

check { deadLocked2 implies not {traces and solved} }