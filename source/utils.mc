using Toybox.System;
using Toybox.Graphics;


function max(a, b) {
    if (a > b) { 
		return a;
	} else { 
		return b;
	}
}

function contains(array, element) {
    	return array.indexOf(element) != -1;
    }

function annulusSector(dc, startdeg, enddeg, startrad, endrad, colour) {
	dc.setColor(colour, colour);
	var width = endrad - startrad;
    dc.setPenWidth(width);
    dc.drawArc(
    dc.getWidth() / 2,                     
    dc.getHeight() / 2,       
    startrad + width / 2,
    Graphics.ARC_COUNTER_CLOCKWISE,
    startdeg + 90,
    enddeg + 90);
}