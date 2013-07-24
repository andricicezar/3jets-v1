$(document).on("mousedown", "#ajax-toggle", function() {
  if ($.cookie("ajax-setting")) {
    $.removeCookie("ajax-setting");
  } else {
    $.cookie("ajax-setting", "true");
  }
  window.location.reload();
});

$(document).on("mousedown", "#transition-toggle", function() {
  if ($(".nnavbar").css("transition-property") == "none") {
    $.removeCookie("transition-setting");
    window.location.reload();
  } else {
    $.cookie("transition-setting", "true");
    disable_all_transitions();
  }
});

$(document).on("mousedown", "#facebook-finder-toggle", function() {
  $.get("/facebook_delete_option");
});

function disable_all_transitions() {
  v = [".nnavbar",
     "#timer",
     ".plane_area .draggable-airplane",
     ".states",
     ".buton .buton-wrp",
     ".buton .text",
     ".buton.active"];
  $.each(v, function(i, item) {
    $(item).css("transition", "none");
  });
  v = ["#box1", "#box2", ".ricon.attention"];
  $.each(v, function(i, item) {
    $(item).css("animation", "none");
    $(item).css("-webkit-animation", "none");
  }); 
}

readySettings = function() {
  if ($.cookie("transition-setting") == "true") {
    $("#transition-toggle input").attr("checked", true);
    disable_all_transitions();
  }
  if ($.cookie("ajax-setting") == "true") {
    $("#ajax-toggle input").attr("checked", true);
  }
}

$(document).ready(readySettings);
$(document).on("page:load", readySettings);
