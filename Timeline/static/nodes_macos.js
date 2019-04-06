var network;
var state;
var nodesCache;
var edgesCache;

var timeline

var displayedData = [];

function webviewReady() {
    callNativeApp()
}

function callNativeApp() {
    try {
        webkit.messageHandlers.webviewreadyHandler.postMessage("webview_ready");
    } catch(err) {
        console.log('The native context does not exist yet');
    }
}

function init(data) {

    displayedData = data
    
    // DOM element where the Timeline will be attached
    var container = document.getElementById('visualization');
    
    // Create a DataSet (allows two way data-binding)
    var items = new vis.DataSet(data);

    // Configuration for the Timeline
    var options = {};

    // Create a Timeline
    timeline = new vis.Timeline(container, items, options);
    
    timeline.on('select', function(properties) {
        var selectedIds = timeline.getSelection();
        
        if (selectedIds.length > 0) {
            var selectedItem = items.get({
                                 filter: function (item) {
                                 return item.id == selectedIds[0]
                                 }
                                 })[0];
        
            webkit.messageHandlers.selectHandler.postMessage(selectedItem.id);
        } else {
            webkit.messageHandlers.deselectHandler.postMessage("deselectHandler");
        }
    });

    
}

function selectTicket(id) {
//    var selectedTicket = displayedData.filter(function(node) {
//       return node.id == id
//    })[0];
    
    //timeline.focus(id)
    timeline.setSelection(id)
    webkit.messageHandlers.selectHandler.postMessage(id);
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
