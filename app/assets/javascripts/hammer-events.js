$(document).ready(function() {
  if ($("meta[name='viewport']").length) {
    // rotate airplanes
    $(document).off("click", ".draggable-airplane", rotate_airplane);
    $(document).hammer().on("tap", ".draggable-airplane", rotate_airplane);

    // open nnavbar in landscape
    $(document).hammer().on("tap", ".nnavbar", function() {
      if ($(".nnavbar").width() < 60) {
        toggle_nnavbar();
      }
    });

    // mega-super-awesome-buton
      // first button
      $(".buton").removeClass("noHammer");
      $(document).on("click", ".buton a[href]", function() {
        return false;
      });
      $(document).hammer().on("tap", ".buton.active a[href]", function() {
        Turbolinks.visit($(this).attr("href"));
      });

      // second button
      $(document).off("click","#search-friend",search_friend_fnc);
      $(document).hammer().on("tap", ".buton.active #search-friend", function(e) {
        setTimeout(function() {
          search_friend_fnc(e);
        }, 100);
      });

    $(document).hammer().on("tap", ".buton", function() {
      setTimeout(function() {
        $(".buton").addClass("active");
      }, 100);
    });
  }
});
