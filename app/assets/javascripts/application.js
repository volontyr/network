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
//= require jquery_ujs
//= require turbolinks
//= require_tree .

function generate_network(network) {
    var $myCanvas = $('#myCanvas');
    var nodes = network.data.nodes;
    var channels = network.data.channels;

    $myCanvas.clearCanvas();

    for (var i = 0; i < channels.length; i++) {
        var first_node = channels[i].first_node;
        var second_node = channels[i].second_node;
        $myCanvas.drawLine({
            layer: true,
            name: "channel" + first_node + second_node,
            strokeStyle: "black",
            strokeWidth: 5,
            draggable: true,
            x1: nodes[channels[i].first_node].coord_x, y1: nodes[channels[i].first_node].coord_y,
            x2: nodes[channels[i].second_node].coord_x, y2: nodes[channels[i].second_node].coord_y
        });
    }

    for(var i = 0; i < nodes.length; i++) {
        $myCanvas.drawArc({
            layer: true,
            draggable: true,
            bringToFront: true,
            name: "name" + i,
            fillStyle: "steelblue",
            x: nodes[i].coord_x, y: nodes[i].coord_y,
            radius: 30,
            shadowX: -1, shadowY: 8,
            shadowBlur: i,
            shadowColor: 'rgba(0, 0, 0, 0.8)',
            drag: function(layer) {
                var layerName = layer.name;
                nodes[parseInt(layerName.slice(-1))].coord_x = layer.x;
                nodes[parseInt(layerName.slice(-1))].coord_y = layer.y;
                nodes[parseInt(layerName.slice(-1))].channels.forEach(function (channel) {
                    var channelName = "channel" + channel.first_node + channel.second_node;
                    $myCanvas.getLayer(channelName).x1 = nodes[channel.first_node].coord_x;
                    $myCanvas.getLayer(channelName).y1 = nodes[channel.first_node].coord_y;
                    $myCanvas.getLayer(channelName).x2 = nodes[channel.second_node].coord_x;
                    $myCanvas.getLayer(channelName).y2 = nodes[channel.second_node].coord_y;
                });
            }
        });
    }

}

$(document).ready(function() {

});
