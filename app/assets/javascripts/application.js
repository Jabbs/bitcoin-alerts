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
//= require jquery.remotipart
//= require bootstrap.min
//= require bootstrap-switch.min
//= require bootstrap-slider.min
//= require bootstrap-3-typeahead.min
//= require chart
//= require Chart.min
//= require gmaps/google
//= require underscore
//= require_tree .

$(function() {

  $(".currency-picker svg").mouseover(function(e) {
    var hexidecimal = $(this).parent().attr("data-hexidecimal");
    $(this).find("path").css({ fill: hexidecimal });
  });

  $(".currency-picker svg").mouseleave(function(e) {
    $(this).find("path").css({ fill: "white" });
  });

  $.get("currencies.json", function(data) {
    $(".typeahead").typeahead({ source: data });
    $(".typeahead").focus();
  },'json');

  var searchReplacing = false;
  $(".typeahead").change(function(e) {
    var current = $(".typeahead").typeahead("getActive");
    if (current && current.name == $(".typeahead").val() && !searchReplacing) {
      searchReplacing = true;
      $(".typeahead").prop('disabled', true);
      $(".search-icon-container").append("<i class='fa fa-2x fa-spinner fa-pulse'></i>");
      location.replace('/channels?search_value=' + current.name);
    }
  });

});
