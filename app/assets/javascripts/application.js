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
            groups: ["channel_and_text" + i],
            dragGroups: ["channel_and_text" + i],
            strokeStyle: "black",
            strokeWidth: 2,
            draggable: true,
            x1: find_node(nodes, first_node).coord_x, y1: find_node(nodes, first_node).coord_y,
            x2: find_node(nodes, second_node).coord_x, y2: find_node(nodes, second_node).coord_y,
            contextmenu: function (layer) {
                var node_1 = layer.name.match(/\d+/g)[0];
                var node_2 = layer.name.match(/\d+/g)[1];
                var channel = find_channel(channels, node_1, node_2);
                var modal_window = $('#modal_form');

                modal_window.find('#weight').val(channel.weight);
                modal_window.find('#error_prob').val(channel.error_prob.toFixed(2));
                modal_window.find('#type').val(channel.type);
                modal_window.find('#connection_type').val(channel.json_class);
                modal_window.find('#activity').val(channel.activity);
                $('#overlay').fadeIn(100, function() {
                    $('#modal_form')
                        .css('display', 'block')
                        .animate({opacity: 1, top: '50%'}, 100);
                });

                $('#update_channel').on("click", function() {
                    close_modal_window();
                    update_channel(channel);
                    // location.reload(true);
                });

                $('#delete_channel').on("click", function() {
                    close_modal_window();
                    delete_channel(channel);
                    // location.reload(true);
                });
            },
            mouseover: function (layer) {
                $myCanvas.getLayer(layer.name).strokeWidth = 8;
            },
            mouseout: function (layer) {
                $myCanvas.getLayer(layer.name).strokeWidth = 2;
            }
        }).drawText({
            layer: true,
            groups: ["channel_and_text" + i],
            text: channels[i].weight,
            fontSize: 20,
            name:  first_node + "channel_weight" + second_node,
            x: (find_node(nodes, first_node).coord_x + find_node(nodes, second_node).coord_x) / 2,
            y: (find_node(nodes, first_node).coord_y + find_node(nodes, second_node).coord_y) / 2,
            fillStyle: 'white',
            strokeStyle: 'darkred',
            strokeWidth: 1
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
                nodes[layerName.match(/\d+/)[0]].coord_x = layer.x;
                nodes[layerName.match(/\d+/)[0]].coord_y = layer.y;
                nodes[layerName.match(/\d+/)[0]].channels.forEach(function (channel) {
                    var channelName = channel.first_node + "channel" + channel.second_node;
                    var channelWeight = channel.first_node + "channel_weight" + channel.second_node;
                    $myCanvas.getLayer(channelName).x1 = find_node(nodes, channel.first_node).coord_x;
                    $myCanvas.getLayer(channelName).y1 = find_node(nodes, channel.first_node).coord_y;
                    $myCanvas.getLayer(channelName).x2 = find_node(nodes, channel.second_node).coord_x;
                    $myCanvas.getLayer(channelName).y2 = find_node(nodes, channel.second_node).coord_y;
                    $myCanvas.getLayer(channelWeight).x = ($myCanvas.getLayer(channelName).x1 +
                                                            $myCanvas.getLayer(channelName).x2) / 2;
                    $myCanvas.getLayer(channelWeight).y = ($myCanvas.getLayer(channelName).y1 +
                                                            $myCanvas.getLayer(channelName).y2) / 2;
                });
                network.data.nodes = nodes;
            },
            dragstop: function() {
                save_network_state(network);
            },
            contextmenu: function (layer) {
                var node_id = layer.name.match(/\d+/g)[0];
                var node = find_node(nodes, node_id);
                var modal_window = $('#node_info');
                var routes_table = "<strong>Routes</strong><br>";

                for (var key in node.routes_table) {
                   routes_table += "<strong>" + key + "</strong> :         ";
                   for (var value in node.routes_table[key]) {
                       routes_table += "  ->  " + node.routes_table[key][value];
                   }
                    routes_table += "<br>";
                }

                modal_window.find('#activity').val(node.activity);
                modal_window.find('#routes_table').html(routes_table);
                $('#overlay-2').fadeIn(100, function() {
                    $('#node_info')
                        .css('display', 'block')
                        .animate({opacity: 1, top: '50%'}, 100);
                });

                $('#update_node').on("click", function() {
                    $('#node_info').animate({opacity: 0, top: '45%'}, 100,
                        function() {
                            $(this).css('display', 'none');
                            $('#overlay-2').fadeOut(200);
                        }
                    );
                    update_node(node);
                    // location.reload(true);
                });

                $('#delete_node').on("click", function() {
                    $('#node_info').animate({opacity: 0, top: '45%'}, 100,
                        function() {
                            $(this).css('display', 'none');
                            $('#overlay-2').fadeOut(200);
                        }
                    );
                    delete_node(node);
                    // location.reload(true);
                });
            },
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

function find_channel(channels, first_node, second_node) {
    for (var i = 0; i < channels.length; i++) {
        if (channels[i].first_node == first_node && channels[i].second_node == second_node)
            return channels[i];
    }
}

function save_network_state(network) {
    $.ajax({
        type: "POST",
        url: "/network/update",
        data: { network : JSON.stringify(network.data) },
        success: function() {
            return true;
        },
    });
}

function update_channel(channel) {
    $.redirect('/network/update_channel', {
        first_node  : channel.first_node,
        second_node : channel.second_node,
        weight      : $("#modal_form").find("#weight").val(),
        error_prob  : $("#modal_form").find("#error_prob").val(),
        type        : $("#modal_form").find("#type").val(),
        activity    : $("#modal_form").find("#activity").val()
    });
    // $.ajax({
    //     type: "POST",
    //     url: "/network/update_channel",
    //     data: {
    //         first_node  : channel.first_node,
    //         second_node : channel.second_node,
    //         weight      : $("#modal_form").find("#weight").val(),
    //         error_prob  : $("#modal_form").find("#error_prob").val(),
    //         type        : $("#modal_form").find("#type").val(),
    //         activity    : $("#modal_form").find("#activity").val()
    //     },
    //     success: function() {
    //         // location.reload(true);
    //         return true;
    //     },
    // });
}

function delete_channel(channel) {
    $.redirect('/network/remove_channel', {
        node_1 : channel.first_node,
        node_2 : channel.second_node,
    });

    // $.ajax({
    //     type: "POST",
    //     url: "/network/remove_channel",
    //     data: {
    //         node_1  : channel.first_node,
    //         node_2 : channel.second_node,
    //     },
    //     success: function() {
    //         // location.reload(true);
    //         return true;
    //     },
    // });
}

function update_node(node) {
    $.redirect('/network/update_node', {
        node     : node.id,
        activity : $("#node_info").find("#activity").val()
    });
    // $.ajax({
    //     type: "POST",
    //     url: "/network/update_node",
    //     data: {
    //         node     : node.id,
    //         activity : $("#node_info").find("#activity").val()
    //     },
    //     success: function() {
    //         // location.reload(true);
    //         return true;
    //     },
    // });
}

function delete_node(node) {
    $.redirect('/network/remove_node', {
        node  : node.id,
    });
    // $.ajax({
    //     type: "POST",
    //     url: "/network/remove_node",
    //     data: {
    //         node  : node.id,
    //     },
    //     success: function() {
    //         // location.reload(true);
    //         return true;
    //     },
    // });
}

function close_modal_window() {
    $('#modal_form').animate({opacity: 0, top: '45%'}, 100,
        function() {
            $(this).css('display', 'none');
            $('#overlay').fadeOut(200);
        }
    );
}

$(document).ready(function() {
    var network = $('#network').data('networkObj');
    generate_network(network);

    // $(document).ajaxError( function(e, xhr, options){
    //     if("500" == xhr.status) {
    //         $(location).attr('href','/network');
    //     }
    // });

    $('.dropdown-menu').on('click', function(event) {
        event.stopPropagation();
    });

    $('#modal_close, #overlay').click(close_modal_window);

    $('#node_info #modal_close, #overlay-2').click(function () {
        $('#node_info').animate({opacity: 0, top: '45%'}, 100,
            function () {
                $(this).css('display', 'none');
                $('#overlay-2').fadeOut(200);
            }
        );
    });
});
