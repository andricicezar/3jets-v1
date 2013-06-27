/*
 *=require jqueryuitouch
 *=require avioaneplay
 *=require sonic
 */

var m;
var k;
readyDragDrop = function(){
	$("#plane1").attr("rot", 1);
	$("#plane2").attr("rot", 1);
	$("#plane3").attr("rot", 1);
	$(".airplane").draggable();
	$(".airplane").draggable({containment: ".grid"});
	$(".airplane").draggable("option", ".grid", ".grid");
	$(".airplane").droppable({
		activeClass:"ui-state-hover",
		hoverClass:"ui-state-active"
	});
	$( ".airplane" ).draggable({ snap: ".square" });
	var i1 = 1;
	var i2 = 1;
	var i3 = 1;
	k = [{}, 
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
	$(".airplane").draggable({
		stop: function() {
			verif();
		}
	});

	function verif() {
		m=[];
		for (i = 0 ;i<10;++i) 
		{
			m[i] = [];
			for (j = 0; j < 10; ++j)
				m[i][j] = 0;
		}
		$.each($(".airplane"),function(){
			var x = $(this).offset();
			x.left-=$(".grid").offset().left;
			x.top-=$(".grid").offset().top;
			x.left=x.left/40;
			x.top/=40;
			rot = $(this).attr("rot");
			if( ((rot == 1 || rot == 3) && x.top < 7 && x.left < 6) ||
				((rot == 2 || rot == 4) && x.top < 6 && x.left < 7)) {
				for (i = 0; i < 10; ++i) {
					if (++m[x.top+k[rot].top[i]][x.left+k[rot].left[i]] > 1) {
						$(this).css("top", 0);
						$(this).css("left", 0);
						break;
					}
				}
			} else {
				$(this).css("top", 0);
				$(this).css("left", 0);				
			}
		});
	}
	$("#plane1").click(function(){
		$("#plane1").removeClass("rotation" + i1);
		if(i1 == 4) i1=0;
		$("#plane1").addClass("ui-draggable ui-droppable rotation" + (i1+1));
		$("#plane1").attr("rot", (i1+1));
		i1++;
		verif();
	});
	$("#plane2").click(function(){
		$("#plane2").removeClass("rotation" + i2);
		if(i2 == 4) i2=0;
		$("#plane2").addClass("ui-draggable ui-droppable rotation" + (i2+1));
		$("#plane2").attr("rot", (i2+1));
		i2++;
		verif();
	});
	$("#plane3").click(function(){
		$("#plane3").removeClass("rotation" + i3);
		if(i3 == 4) i3=0;
		$("#plane3").addClass("ui-draggable ui-droppable rotation" + (i3+1));
		$("#plane3").attr("rot", (i3+1));
		i3++;
		verif();
	});
	$("#send-button").click(function(){
		var ok = true;
		$.each($(".airplane"),function(){
			var x = $(this).position();
			if(x.top == 0) ok = false;
		});
		if(ok == false) 
		{
			alert("Put all planes on grid!");
			return;
		}
		var cr = "";
		$.each($(".airplane"),function(){
			var x = $(this).offset();
			x.left-=$(".grid").offset().left;
			x.top-=$(".grid").offset().top;
			x.left=x.left/40;
			x.top/=40;
			rot = $(this).attr("rot");
			cr = cr + "1" + x.top + x.left + rot;
		});
		if ($("#game-id").attr("game") != undefined)
		    	window.location = "../match/"+cr + "?game=" + $("#game-id").attr("game");
		else
			window.location = "../match/"+cr
	});

}
$(document).ready(readyDragDrop);
$(document).on("page:load", readyDragDrop);

