var network;
var state;
var nodesCache;
var edgesCache;

var UISTATE = "";
var toJoin = 0;

function webviewReady() {
    callNativeApp()
}

function callNativeApp() {
    try {
        webkit.messageHandlers.webviewreadyHandler.postMessage("webviewready");
    } catch(err) {
        console.log('The native context does not exist yet');
    }
}

function init(graph) {
    try {

        nodesCache = new vis.DataSet(graph.nodes);
        edgesCache = new vis.DataSet(graph.edges);

        var container = document.getElementById('mynetwork');
        var options = {
            nodes: {
                shape: 'dot',
                size: 1,
                scaling: {
                    min: 5,
                    label: {
                        enabled: true,
                        min: 2
                    },
                    customScalingFunction: function (min, max, total, value) {
                        if (value < min) {
                            return min
                        } else {
                            return value
                        }
                    }
                },
                font: {
                    face: 'Optima',
                    color: '#dae3f1',
                    size: 7
                }
            },
            edges: {
                arrows: 'to',
                color: {
                    inherit: 'from'
                }
            },
            groups: {
                "0": { color: '#4FFBDF', borderWidth:0, mass: 1 },
                "1": { color: '#845EC2', borderWidth:0, mass: 1.1 },
                "2": { color: '#D65DB1', borderWidth:0, mass: 1.3 },
                "3": { color: '#FF6F91', borderWidth:0, mass: 1.4 },
                "4": { color: '#FF9671', borderWidth:0, mass: 1.5 },
                "5": { color: '#FFC75F', borderWidth:0, mass: 1.6 },
                "6": { color: '#F9F871', borderWidth:0, mass: 1.7 },
                "7": { color: '#008F7A', borderWidth:0, mass: 1.8 },
                "8": { color: '#CB963D', borderWidth:0, mass: 1.9 },
                "9": { color: '#ccff33', borderWidth:0, mass: 1 }, // DONE
                "10": { color: '#444444', borderWidth:0, mass: 1 } // DONE

            },
            physics: {
                forceAtlas2Based: {
                    gravitationalConstant: -20,
                    centralGravity: 0.003,
                    springLength: 180,
                    springConstant: 0.5
                },
                maxVelocity: 146,
                solver: 'forceAtlas2Based',
                timestep: 0.35,
                stabilization: {iterations: 150}
            },
            layout: {
                randomSeed: 0
            }
        };

        var data = {
            nodes: nodesCache,
            edges: edgesCache,
            options: options
        };

        network = new vis.Network(container, data, options);

        network.on("selectNode", function (params) {
            var selectedNodeId = network.getSelection().nodes[0];
            var selectedNode = nodesCache.get(selectedNodeId);

            if (UISTATE == "JOIN") {
                try {
                   webkit.messageHandlers.linkNodesHandler.postMessage({"to": network.getSelection().nodes[0], "from": toJoin });
                } catch(err) {
                    console.log('The native context does not exist yet');
                }
            } else if (UISTATE == "JOIN_PARENT") {
               try {
                   webkit.messageHandlers.linkNodeParentsHandler.postMessage({"to": network.getSelection().nodes[0], "from": toJoin });
               } catch(err) {
                   console.log('The native context does not exist yet');
               }
            } else {
                //webkit.messageHandlers.selectNodesHandler.postMessage(network.getSelection().nodes[0]);
            }

        });
        
        network.on("click", function (params) {
               try {
                   webkit.messageHandlers.clickHandler.postMessage({"node": network.getSelection().nodes[0]});
               } catch(err) {
                   console.log('The native context does not exist yet');
               }
        });

        network.on("doubleClick", function (params) {
            try {
                webkit.messageHandlers.doubleClickHandler.postMessage({"node": network.getSelection().nodes[0]});
            } catch(err) {
                console.log('The native context does not exist yet');
            }
        });

        network.on("deselectNode", function() {
            webkit.messageHandlers.deselectNodesHandler.postMessage(network.getSelection().nodes);
        });
    } catch (e) {
        return e
    }

    return graph.edges
}

function updateGraph(graph) {
//    nodesCache.update(graph.nodes);
//    edgesCache.update(graph.edges);
    //nodesCache.clear()
    edgesCache.clear()
    
    //nodesCache.add(graph.nodes)
    edgesCache.add(graph.edges)
    
//    nodesCache = new vis.DataSet(graph.nodes);
//    edgesCache = new vis.DataSet(graph.edges);
//
//    redraw()
}

function redraw() {
    network.redraw()
}

function getSelection() {
    return {
        "nodes": network.getSelectedNodes(),
        "edges": network.getSelectedEdges()
    }
}

function getSelectedNodes() {
    return network.getSelectedNodes();
}

var addNodes = function(nodes) {
    // Accepts single or array of objects
    return nodesCache.update(nodes)
}

var removeNodes = function(nodes) {
    // Accepts single or array of objects
    nodesCache.remove(nodes)
}

var addEdges = function(to, from) {
    // Accepts single or array of objects
    return edgesCache.update({
        to: to,
        from: from
    })
}

var removeEdges = function(edge) {
    // Accepts single or array of objects
    //edgesCache.remove(edge.id)
    edgesCache.remove(
                      edgesCache.getIds({
                          filter: function(e) {
                            return e.to == edge.to && e.from == edge.from
                          }
    }))
    
    
}

var selectNodes = function(nodes) {
    network.selectNodes(nodes)
}

var removeSelectedEdge = function(edgeId) {
    edgesCache.remove(edgeId);
}

function setCursorByID(id,cursorStyle) {
    if (id.style) id.style.cursor=cursorStyle;
}

// CLICK HANDLERS
$( document ).ready(function() {
    $('#remove-node').click(function() {
        confirmDeleteSelectedNode();
    });

    $('#join-node').click(function() {
       UISTATE = "JOIN";
       toJoin = network.getSelection().nodes[0];
    });

    $('#delete-selected-node').click(function() {
        if (network.getSelectedNodes().length > 0) {
            webkit.messageHandlers.deleteNodeHandler.postMessage(network.getSelectedNodes()[0]);
        } else if (network.getSelectedEdges().length > 0) {
            var selectedEdge = edgesCache.get(network.getSelectedEdges()[0]);
            selectedEdge.id = network.getSelectedEdges()[0]

            if (selectedEdge) {
                webkit.messageHandlers.deleteEdgeHandler.postMessage(selectedEdge)
            } else {
                webkit.messageHandlers.deleteEdgeHandler.postMessage({from: "", to: ""})
            }
        }
    });
});

var confirmDeleteSelectedNode = function() {
    if (network.getSelectedNodes().length > 0 || network.getSelectedEdges().length > 0) {
        $('.ui.basic.modal').modal('show');
    } else {
        // TODO provide feedback
    }
}

function find(nodesCache, inputValue) {
    var filteredNodeIds = [];

    nodesCache.forEach(function(node) {
        if (inputValue != "" && node.label.toLowerCase().indexOf(inputValue.toLowerCase()) !== -1) {
            filteredNodeIds.push(node.id);
        }
    });

    return filteredNodeIds;
}

function fit(nodeIDs) {
    network.fit({
        nodes: nodeIDs,
        animation: {
            duration: 500,
            easingFunction: 'easeInQuad'
        }
    });
}

function bodyKeyDownHandler(event) {
    if (event.key === "Escape") {
        switch (UISTATE) {
            case "JOIN":
                UISTATE = ""
                toJoin = 0
                setCursorByID(document.body, 'default');
                break;
            case "JOIN_PARENT":
                UISTATE = ""
                toJoin = 0
                setCursorByID(document.body, 'default');
                break;
        }
    }
}

function bodyKeyPressHandler(event) {
    if (event.ctrlKey === true) {
        switch (event.key) {
            case 'd':
                confirmDeleteSelectedNode();
                break;
            case 's':
                var nodes = network.getSelection().nodes
                if (nodes.length === 0) {
                    break
                }
                UISTATE = "JOIN";
                toJoin = network.getSelection().nodes[0];
                setCursorByID(document.body, 'crosshair');
                break;
            case 'p':
                var nodes = network.getSelection().nodes
                if (nodes.length === 0) {
                    break
                }
                UISTATE = "JOIN_PARENT";
                toJoin = network.getSelection().nodes[0];
                setCursorByID(document.body, 'crosshair');
                break;

        }
    }
}

var beforeSearchView;

function focusOnNode(id) {
    network.focus(id, {
        scale: 1.8,
        animation: {
            duration: 300,
            easingFunction: 'easeInQuad'
        }
    });
}
