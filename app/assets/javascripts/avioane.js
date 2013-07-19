/*
 *=require jqueryuitouch
 *=require avioaneplay
 *=require sonic
 */

var m;
// CONFIGURATIA AVIONULUI PE CELE 4 DIRECTII
var k = [{}, 
		{
			top:  [2, 0, 2, 0, 1, 2, 3, 0, 2, 2], 
			left: [0, 1, 1, 2, 2, 2, 2, 3, 3, 4]
		}, {
			top:  [2, 0, 1, 2, 3, 4, 2, 1, 2, 3], 
			left: [0, 1, 1, 1, 1, 1, 2, 3, 3, 3]
		}, {
			top:  [1, 1, 3, 0, 1, 2, 3, 1, 3, 1], 
			left: [0, 1, 1, 2, 2, 2, 2, 3, 3, 4]
		}, {
			top:  [1, 2, 3, 2, 0, 1, 2, 3, 4, 2], 
			left: [0, 0, 0, 1, 2, 2, 2, 2, 2, 3]
		}];

// FUNCTIA CARE ROTESTE AVIOANELE
$(document).on("click", ".draggable-airplane", rotate_airplane);
function rotate_airplane(e) {
  console.log(e);
  var rot = $(this).attr("rot");
  $(this).removeClass("rotation" + rot);
  ++rot;
  if (rot == 5) rot = 1;
  $(this).addClass("rotation"+rot);
  $(this).attr("rot", rot);
  verif_airplanes();
}


// CAND PAGINA E INCARCATA
var squareSize;
readyDragDrop = function() {
  // in caz ca dimensiunile sunt prea mici, dam resize
  if (window.innerWidth <= 800 && window.innerWidth <= window.innerHeight) {
    size = Math.floor((window.innerWidth - 30)/11)*11;
    $(".main_grid").css({
      "width": size,
      "height": size,
      "margin": "0 auto"
    });
    squareSize = $(".grid td").width() + parseInt($(".grid td").css("border-left-width")) + parseInt($(".grid td").css("border-right-width"));
    $(".information").css("width", window.innerWidth - squareSize * 5 - 35);
  }

  // resize table
  $(".main_grid table").css({
    "width": $(".main_grid .grid").width()+1,
    "height": $(".main_grid .grid").height()+1
  });
  squareSize = $(".grid td").width() + parseInt($(".grid td").css("border-left-width")) + parseInt($(".grid td").css("border-right-width"));

  // resize la avioane (modificam doar plane area)
  $(".plane_area").css({
    "width":  squareSize * 5,
    "height": squareSize * 4,
    "margin-bottom": squareSize
  });

  // resize text grid
  $(".mark").css({
    "font-size": 0.5 * squareSize,
    "line-height": squareSize + "px"
  });

  // adaug avioanele/loviturile
  init_grid();

  // activam avioanele care au nevoie de drag and drop
	$(".draggable-airplane").attr("rot", 1);
	$(".draggable-airplane").draggable({
    containment: ".grid table",
    stop: function() {
      verif_airplanes();
    },
    snap: ".grid td",
    snapTolerance: squareSize-1
  }).droppable({
    activeClass:"ui-state-hover",
    hoverClass:"ui-state-active"
  });

}
$(document).ready(readyDragDrop);
$(document).on("page:load", readyDragDrop);

// VERIFICAM DACA AVIOANELE NU IES DIN GRID
// VERIFICAM DACA AVIOANELE NU SUNT SUPRAPUSE
function verif_airplanes() {
  m=[];
  for (i = 0; i < 10; ++i) {
    m[i] = [];
    for (j = 0; j < 10; ++j) {
      m[i][j] = 0;
    }
  }
  $.each($(".draggable-airplane"),function(){
    var x   = $(this).offset();
    x.left -= $(".grid table").offset().left + parseInt($(".grid table").css("border-left-width"));
    x.top  -= $(".grid table").offset().top + parseInt($(".grid table").css("border-top-width"));
   
    x.left /= squareSize;
    x.top  /= squareSize;
    rot = parseInt($(this).attr("rot"));

    if( ((rot == 1 || rot == 3) && x.top < 7 && x.left < 6) ||
        ((rot == 2 || rot == 4) && x.top < 6 && x.left < 7)) {
      for (i = 0; i < 10; ++i) {
        if (++m[ x.top+k[rot].top[i] ][ x.left+k[rot].left[i] ] > 1) {
          $(this).css("top", 0)
                 .css("left", 0);
          break;
        }
      }
    } else {
      $(this).css("top", 0)
             .css("left", 0);				
    }
  });
}

$(document).on("click", "#send-button", function() {
  // verificam daca toate avioanele sunt pe grid
  var ok = true;
  $.each($(".draggable-airplane"), function() {
    var x = $(this).position();
    if(x.top == 0) ok = false;
  });
  if(ok == false) {
    alert("Put all planes on grid!");
    return;
  }

  //memoram pozitia fiecarui avion
  var cr = "";
  $.each($(".draggable-airplane"), function() {
    // calculam pozitia pe grid
    var x   = $(this).offset();
    x.left -= $(".grid table").offset().left + parseInt($(".grid table").css("border-left-width"));
    x.top  -= $(".grid table").offset().top + parseInt($(".grid table").css("border-top-width"));
    x.left /= squareSize;
    x.top  /= squareSize;
    rot     = $(this).attr("rot");
    cr      = cr + "1" + x.top + x.left + rot;
  });

  // redirectam catre queue
  if ($("#game-id").attr("game") != undefined) {
    Turbolinks.visit("../match/"+cr + "?game=" + $("#game-id").attr("game"));
  } else {
    Turbolinks.visit("../match/"+cr);
  }
});


