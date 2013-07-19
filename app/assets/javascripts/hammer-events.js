//= require hammer
if (typeof Hammer != "undefined") {
  $(document).off("click", ".draggable-airplane", rotate_airplane);
  $(document).hammer().on("tap", ".draggable-airplane", rotate_airplane);

  $(document).hammer().on("tap", ".nnavbar", toggle_nnavbar);

}
