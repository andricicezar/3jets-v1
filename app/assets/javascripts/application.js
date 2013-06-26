// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require bootstrap-dropdown
//= require bootstrap-button
//= require faye_conn
//= require angular
//= require ang-onlineCtrl
//= require ang-autoCompleteModule
//= require avioane

$(function() {
  $(".follow-btn").click(function() {
    button = $(this);
    button.addClass("disabled");
    $.get("../user/" +button.attr("user") + "/friend", "json")
      .done(function() {
        location.reload();
      }).fail(function(x, y, z) {
        button.removeClass("disabled");
      });
  });
  setInterval(function() {
    $.get("/check");
  }, 30000);
  $("#search-friend").click(function(event) {
    $("body").one("click", function() {
      $("#search-friend").parent().parent().removeClass("active");
      $("#search-friend-popover").removeClass("active");
    });

    var button = $("#search-friend");
    button.parent().parent().addClass("active");
    var popover = $("#search-friend-popover");
    popover.addClass("active");
    popover.css("top", button.offset().top);
    popover.css("left", button.offset().left + button.width());
    event.stopPropagation();
  });
  $("#search-friend-popover").click(function(event) {
    $("#search-friend").parent().parent().addClass("active");
    $("#search-friend-popover").addClass("active");
    event.stopPropagation();
  });

  mega_awesome_button = $(".mega-super-awesome-button");
  mega_awesome_button
    .css("position", "fixed")
    .css("top", "40%")
    .css("left", "50%")
    .css("margin-top", -mega_awesome_button.height()/2)
    .css("margin-left", -mega_awesome_button.width()/2);
});

function expandNotif(notif) {
  notif.toggleClass("expanded");
}
function reqBtn(btn) {
  $.get($(btn).attr("href"));
  $(this).remove();
  return false;
}
