readyGame = function() {
  if (typeof faye == "undefined") {
    connect_to_faye(game_ready);
  } else {
    game_ready();
  }
}
$(document).ready(readyGame);
$(document).on("page:load", readyGame);
function game_ready() {
  if ($("#wait").length > 0) {
    s = "/game/"+$("#wait").attr("game")+"/add_user";
    faye.subscribe(s, function(data) {
      alert("We found an opponent!");
      window.location = "../"+$("#wait").attr("game");
    });
  }
  init_grid();
  if ($("#main_grid2").length > 0) {
    s = "/game/"+$("#main_grid1").attr("game")+"/move";
    faye.subscribe(s, function(data) {
      if (data == "4") {
        window.location += "/victory";
      }
      qtop = data[data.length-3];
      qleft = data[data.length-2];
      qhit = data[data.length-1];
      data = data.slice(0, data.length-3);
      if (data == $("#main_grid1").attr("user")) {
        $("#main_grid2 .casuta"+qtop+"-"+qleft+"").addClass("hit-"+qhit).addClass("basic-sprite");
      } else {
        $("#main_grid1 .casuta"+qtop+"-"+qleft).addClass("hit-"+qhit).addClass("basic-sprite");
      }
      if (qhit == 0) {
        schimba_rolurile();
      }
    });
    $("#main_grid2 .square").click(function() {
      if (!$(this).hasClass("hit-0") && !$(this).hasClass("hit-1") && !$(this).hasClass("hit-2")) {
        cl =  $(this).attr("class");
        link = window.location + "/move";

        $.get(link, {top: cl[13], left: cl[15]}, function (data) {
          if (data == '3') alert("It's not your turn!");
       }).fail(function() {console.log("fail");});
      }
    });
  }
}

function schimba_rolurile() {
  $("#main_grid2").toggleClass("not-your-turn");
  $.each($(".game-users").find("span"), function(i, item) {
    if ( $(item).hasClass("current_user") ) {
      $(item).removeClass("current_user");
    } else {
      $(item).addClass("current_user");
    }
  });
}

function init_grid() {
  $.each($(".play_grid"), function(i, item) {
    av = $(item).attr("av");
    $(item).removeAttr("av");
    if (av) {
      for (i = 0; i <= 2; ++i) {
        k = jQuery("<div/>").appendTo($(item).children(".grid"));
        k.addClass("airplane").addClass("basic-sprite");
        k.css("top", av[i*4+1]*40);
        k.css("left", av[i*4+2]*40);
        k.addClass("rotation"+av[i*4+3]);
      }
    }

    val = $(item).attr("lov");
    $(item).removeAttr("lov");
    if (val) {
      for (i = 0; i < val.length; i += 3) {
        $(item).find(".casuta"+val[i]+"-"+val[i+1]).addClass("hit-"+val[i+2]).addClass("basic-sprite");
      }
    }
  });
}
