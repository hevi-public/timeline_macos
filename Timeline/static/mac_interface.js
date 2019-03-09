function errorMessage() {
    webkit.messageHandlers.linkNodesHandler.postMessage({"to": network.getSelection().nodes[0], "from": toJoin });
}
