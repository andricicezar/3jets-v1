// CAND PAGINA SE INCARCA
// VERIFICAM DACA FAYE E PORNIT
readyGame = function() {
  if (typeof faye == "undefined") {
    connect_to_faye(game_ready);
  } else {
    game_ready();
  }
}
$(document).ready(readyGame);
$(document).on("page:load", readyGame);

// HITS HITS
$(document).on("click", "#main_grid2 .square", function() {
  if (!$(this).hasClass("hit-0") && !$(this).hasClass("hit-1") && !$(this).hasClass("hit-2")) {
    cl =  $(this).attr("class");
    link = window.location + "/move";

    $.get(link, {top: cl[13], left: cl[15]}, function (data) {
      if (data == '3') alert("It's not your turn!");
   }).fail(function() {console.log("fail");});
  }
});

var waiting, game_subscribe;
function game_ready() {
  // VEDEM DACA SUNTEM PE WAIT SCREEN
  if ($("#wait").length) {
    // GENERAM CHANNELUL
    s = "/game/"+$("#wait").attr("game")+"/add_user";
    // SUBSCRIBE TO CHANNEL
    // ** prima data verificam daca nu cumva e deja conectat la altul
    // ** daca da, anulam subscribeul
    // ** si cream altul nou
    if (typeof waiting != "undefined") {
      waiting.cancel();
    }
    waiting = faye.subscribe(s, function(data) {
      alert("We found an opponent!");
       // REDIRECTAM
      Turbolinks.visit("../"+$("#wait").attr("game"));
    });
  }
  // PUNEM AVIOANELE SI LOVITURILE PE GRID
  init_grid();

  if ($("#main_grid2").length) {
    var game = $("#main_grid1").attr("game");
  
    // SUBSCRIBE TO CHANNEL
    // ** prima data verificam daca nu cumva e deja conectat la altul
    // ** daca da, anulam subscribeul
    // ** si cream altul nou
    if (typeof game_subscribe != "undefined") {
      game_subscribe.cancel();
    }
    s = "/game/"+game+"/move";
    game_subscribe = faye.subscribe(s, function(data) {
      if ($("#main_grid1").attr("game") == game) {
        if (data == "4") {
          Turbolinks.visit("/game/"+game+"/victory");
        }
        qtop  = data[data.length-3];
        qleft = data[data.length-2];
        qhit  = data[data.length-1];
        data  = data.slice(0, data.length-3);

        // VEDEM A CUI ESTE LOVITURA
        if (data == $("#main_grid1").attr("user")) {
          $("#main_grid2 .casuta"+qtop+"-"+qleft+"")
                                      .addClass("hit-"+qhit)
                                      .addClass("basic-sprite");
        } else {
          $("#main_grid1 .casuta"+qtop+"-"+qleft)
                                      .addClass("hit-"+qhit)
                                      .addClass("basic-sprite");
        }

        schimba_rolurile();
      }
    });
  }
}

function schimba_rolurile() {
  $("#main_grid2").toggleClass("not-your-turn");
  $.each($(".game-users").find("span"), function(i, item) {
      $(item).toggleClass("current_user");
  });
}

function init_grid() {
  // LUAM FIECARE GRID IN PARTE
  $.each($(".play_grid"), function(i, item) {

    // ADAUGAM AVIOANELE
    av = $(item).attr("av");
    $(item).removeAttr("av");
    if (av) {
      for (i = 0; i <= 2; ++i) {
        jQuery("<div/>")
              .appendTo( $(item).children(".grid") )
              .addClass("airplane")
              .addClass("basic-sprite")
              .css("top", av[i*4+1]*40)
              .css("left", av[i*4+2]*40)
              .addClass("rotation"+av[i*4+3]);
      }
    }

    // ADAUGAM LOVITURILE
    val = $(item).attr("lov");
    $(item).removeAttr("lov");
    if (val) {
      for (i = 0; i < val.length; i += 3) {
        $(item).find(".casuta"+val[i]+"-"+val[i+1])
               .addClass("hit-"+val[i+2])
               .addClass("basic-sprite");
      }
    }
  });
}
