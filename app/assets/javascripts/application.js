// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require_tree .

function generate_network(network) {
    var $myCanvas = $('#myCanvas');
    var nodes = network.data.nodes;
    var channels = network.data.channels;

    $myCanvas.removeLayers();
    $myCanvas.clearCanvas();

    for (var i = 0; i < channels.length; i++) {
        var first_node = channels[i].first_node;
        var second_node = channels[i].second_node;
        $myCanvas.drawLine({
            layer: true,
            name: first_node + "channel" + second_node,
            strokeStyle: "black",
            strokeWidth: 2,
            draggable: true,
            x1: find_node(nodes, first_node).coord_x, y1: find_node(nodes, first_node).coord_y,
            x2: find_node(nodes, second_node).coord_x, y2: find_node(nodes, second_node).coord_y
        });
    }

    for(var i = 0; i < nodes.length; i++) {
        $myCanvas.drawArc({
            layer: true,
            draggable: true,
            // bringToFront: true,
            name: "name" + i,
            groups: ["node_and_text" + i],
            dragGroups: ["node_and_text" + i],
            fillStyle: "darkred",
            x: nodes[i].coord_x, y: nodes[i].coord_y,
            radius: 15,
            shadowX: -1, shadowY: 8,
            shadowBlur: i,
            shadowColor: 'rgba(0, 0, 0, 0.8)',
            drag: function(layer) {
                var layerName = layer.name;
                console.log(layerName.match(/\d+/)[0]);
                nodes[layerName.match(/\d+/)[0]].coord_x = layer.x;
                nodes[layerName.match(/\d+/)[0]].coord_y = layer.y;
                nodes[layerName.match(/\d+/)[0]].channels.forEach(function (channel) {
                    var channelName = channel.first_node + "channel" + channel.second_node;
                    $myCanvas.getLayer(channelName).x1 = find_node(nodes, channel.first_node).coord_x;
                    $myCanvas.getLayer(channelName).y1 = find_node(nodes, channel.first_node).coord_y;
                    $myCanvas.getLayer(channelName).x2 = find_node(nodes, channel.second_node).coord_x;
                    $myCanvas.getLayer(channelName).y2 = find_node(nodes, channel.second_node).coord_y;
                });
                network.data.nodes = nodes;
            }
        }).drawText({
            layer: true,
            groups: ["node_and_text" + i],
            text: nodes[i].id,
            fontSize: 20,
            name: "node_number" + i,
            x: nodes[i].coord_x, y: nodes[i].coord_y,
            fillStyle: 'white',
            strokeStyle: 'white',
            strokeWidth: 1
        });
    }
}

function find_node(nodes, id) {
    for (var i = 0; i < nodes.length; i++) {
        if (nodes[i].id == id)
            return nodes[i];
    }
}

$(document).ready(function() {
    var network = $('#network').data('networkObj');
    generate_network(network);

    $('.dropdown-menu').on('click', function(event) {
        event.stopPropagation();
    });

    $("#update_network").click(function () {
        $.ajax({
            type: "POST",
            url: "/network/update",
            data: { network : JSON.stringify(network.data) },
            success: function() {
                return true;
            },
        });
    });
});
