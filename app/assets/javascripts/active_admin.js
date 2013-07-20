//= require jquery
//= require jquery.ui.all
//= require active_admin/base

$(function() {
  init_grid();
});
function init_grid() {
  squareSize = 40;
  // LUAM FIECARE GRID IN PARTE
  $(".play-airplane").remove();
  $.each($(".play_grid"), function(i, item) {
    // ADAUGAM AVIOANELE
    av = $(item).attr("av");
    $(item).removeAttr("av");
    if (av) {
      for (i = 0; i <= 2; ++i) {
        jQuery("<div/>")
              .appendTo( $(item).children(".main_grid").children(".grid") )
              .addClass("airplane play-airplane")
              .css("top", av[i*4+1]*squareSize)
              .css("left", av[i*4+2]*squareSize)
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
