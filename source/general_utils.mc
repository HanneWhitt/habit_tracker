using Toybox.System;
using Toybox.Attention;
using Toybox.Lang;


function print(str) {
	System.println(str);
}


function max(a, b) {
	if (a instanceof Lang.Array) {
		var max = a[0];
		if (a.size() == 1) {
			return max;
		} else {
			for (var mx = 1; mx < a.size(); mx += 1) {
				if (a[mx] > max) {
					max = a[mx];
				}
			}
			return max;
		}
	} else {
		if (a > b) { 
			return a;
		} else { 
			return b;
		}
	}
}

function min(a, b) {
    if (a < b) { 
		return a;
	} else { 
		return b;
	}
}


function contains(array, element) {
    	return array.indexOf(element) != -1;
}


    
function vibrate_with_delay(delay_ms, vibration_ms) {
	if (Attention has :vibrate) {
	    var vibeData =
	    [
	        new Attention.VibeProfile(0, delay_ms), // delay 0.3s
	        new Attention.VibeProfile(50, vibration_ms),  // On for 0.7s
	    ];
	    Attention.vibrate(vibeData);
	}
}

// Vibration, sounds, or other ways that the watch responds to the user momentarily, without changing data 
function respond(response_code) {
	if (response_code.equals("None")) {
	} else if (response_code.equals("vibrate")) {
		vibrate_with_delay(300, 700);
	} else {
		throw new Lang.InvalidValueException("Invalid response code");
	}
}


