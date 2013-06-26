//= require jquery
//= require jquery.ui.all
//= require active_admin/base
$(function() {
  init_grid();
});

function init_grid() {
  $.each($(".play_grid"), function(i, item) {
    av = $(item).attr("av");
    $(item).removeAttr("av");
    if (av) {
      for (i = 0; i <= 2; ++i) {
        k = jQuery("<div/>").appendTo($(item).children(".grid"));
        k.addClass("airplane");
        k.css("top", av[i*4+1]*40);
        k.css("left", av[i*4+2]*40);
        k.addClass("rotation"+av[i*4+3]);
      }
    }

    val = $(item).attr("lov");
    $(item).removeAttr("lov");
    if (val) {
      for (i = 0; i < val.length; i += 3) {
        $(item).find(".casuta"+val[i]+"-"+val[i+1]).addClass("hit-"+val[i+2]);
      }
    }
  });
}
