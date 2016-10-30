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
    console.log(network);
}

$(document).ready(function() {
    // Store the canvas object into a variable
    var $myCanvas = $('#myCanvas');

    $myCanvas.drawArc({
        layer: true,
        draggable: true,
        bringToFront: true,
        name: 'blueSquare',
        fillStyle: 'steelblue',
        x: 450, y: 300,
        radius: 50,
        shadowX: -1, shadowY: 8,
        shadowBlur: 2,
        shadowColor: 'rgba(0, 0, 0, 0.8)'
    }).drawArc({
        layer: true,
        draggable: true,
        bringToFront: true,
        name: 'redSquare',
        fillStyle: 'red',
        x: 500, y: 350,
        radius: 50,
        shadowX: -2, shadowY: 5,
        shadowBlur: 3,
        shadowColor: 'rgba(0, 0, 0, 0.5)'
    });

});
