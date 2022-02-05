using Toybox.System;
using Toybox.Attention;
using Toybox.Lang;


function max(a, b) {
    if (a > b) { 
		return a;
	} else { 
		return b;
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
	    System.println("Watch Vibrated");
	}
}

// Vibration, sounds, or other ways that the watch responds to the user momentarily, without changing data 
function respond(response_code) {
	System.println(response_code);
	if (response_code.equals("None")) {
		System.println("No response");
	} else if (response_code.equals("vibrate")) {
		vibrate_with_delay(300, 700);
	} else {
		throw new Lang.InvalidValueException("Invalid response code");
	}
}


