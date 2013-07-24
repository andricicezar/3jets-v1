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


//$(document).hammer().on("dragright", "body", toggle_nnavbar);
//
$(document).on("click", "#nnavbar-toggle", toggle_nnavbar);
function toggle_nnavbar() {
  $(".nnavbar").toggleClass("active").removeClass("closed");
  $("#nnavbar-toggle").toggleClass("active");
}

function close_nnavbar() {
  $(".nnavbar.active").removeClass("active").addClass("closed");
  $("#nnavbar-toggle.active").removeClass("active");
}
// $(document).on("click", ".nnavbar.active .close-nnavbar", close_nnavbar);

$(document).on("click", ".expandable", function() {
  $(this).toggleClass("expanded");
});

$(document).on("click", "#facebook-friends", function() {
  $.ajax({
    url: "/facebook_friends",
    dataType: "text",
    success: function(data) {
      alert(data);
    }
  });
});

$(document).on("click", "#search-friend", search_friend_fnc);
function search_friend_fnc(event) {
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
}

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

  $("#search_friend_input").unbind("autocomplete");
  $("#search_friend_input").autocomplete({
    source: "/search_friends"
  });

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

// GOOGLE ANALYTICS
google_a = (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-42606685-1', '3jets.com');
ga('send', 'pageview');

// TURBOLINKS SETTINGS
$(document).ready(readyApp);
$(document).on("page:load", readyApp);

$(document).on("page:fetch", function() {
  close_nnavbar();
  $("#wait-is-loading").addClass("active");
  $("#loading-bar").addClass("active");
});
$(document).on("page:receive", function() {
  ga('send', 'pageview');
  $("#wait-is-loading").removeClass("active");
  $("#loading-bar").removeClass("active");
});

function reqBtn(btn) {
  $.get($(btn).attr("href"));
  $(this).remove();
  return false;
}
