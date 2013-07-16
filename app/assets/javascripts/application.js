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
// require jquery.turbolinks
//= require jquery_ujs
//= require jquery.ui.core
//= require jquery.ui.autocomplete
//= require jquery.ui.draggable
//= require jquery.ui.droppable
//= require faye_conn
//= require angular
//= require ang-onlineCtrl
//= require ang-autoCompleteModule
//= require avioane
//= require turbolinks-edited

$(document).on("click", ".follow-btn", function() {
  button = $(this);
  button.addClass("disabled");
  $.get("../user/" +button.attr("user") + "/friend", "json")
    .done(function() {
      location.reload();
    }).fail(function(x, y, z) {
      button.removeClass("disabled");
    });
});

$(document).on("click", "#nnavbar-toggle", function() {
  $(".nnavbar").toggleClass("active").removeClass("closed");
  $("#nnavbar-toggle").toggleClass("active");
});

function close_nnavbar() {
  $(".nnavbar.active").removeClass("active").addClass("closed");
  $("#nnavbar-toggle.active").removeClass("active");
}
$(document).on("click", ".nnavbar.active .close-nnavbar", close_nnavbar);

$(document).on("click", ".expandable", function() {
  $(this).toggleClass("expanded");
});

$(document).on("click", "#search-friend", function(event) {
  $(document).one("click", function() {
    $("#search-friend").parent().parent().removeClass("active");
    $("#search-friend-popover").removeClass("active");
  });

  var button = $("#search-friend");
  button.parent().parent().addClass("active");
  if (window.innerWidth <= 600) {
    $("#search-friend-popover").addClass("active input-top");
    $("#search-friend-popover .arrow").css("display", "none");
  } else {
    $("#search-friend-popover").addClass("active")
                               .css("top", button.offset().top)
                               .css("left", button.offset().left + button.width());
  }
  event.stopPropagation();
});

$(document).on("click", "#search-friend-popover", function(event) {
  $("#search-friend").parent().parent().addClass("active");
  $("#search-friend-popover").addClass("active");
  event.stopPropagation();
});

$(document).on("click", ".profile_images img", function(event) {
  $(".profile_images img").removeClass("active");
  $(this).addClass("active");
  $("#image_link").attr("value", $(this).attr("src"));
});

// SETAM UN INTERVAL CARE MARCHEAZA
// USERUL CA FIIND ONLINE
setInterval(function() {
  $.get("/check");
}, 30000);

readyApp = function() {
  // mega_awesome_button = $(".mega-super-awesome-button");
  // mega_awesome_button
  //  .css("position", "fixed")
  //  .css("top", "40%")
  //  .css("margin-top", -mega_awesome_button.height()/2)
  //  .css("margin-left", -mega_awesome_button.width()/2);
  
  $("#search_user_input").unbind("autocomplete");
  $("#search_user_input").autocomplete({
    source: "/search_users"
  });

  $("#search_user_input").keyup(function(e) {
    var guy;
    if (e.keyCode === 13) {
      guy = $(this).val();
      return $.each($(".ui-menu-item a"), function(i, v) {
        if ($(v).text() === guy) {
          Turbolinks.visit($(v).attr("href"));
        }
      });
    }
  });
}
$(document).ready(readyApp);
$(document).on("page:load", readyApp);

function reqBtn(btn) {
  $.get($(btn).attr("href"));
  $(this).remove();
  return false;
}
