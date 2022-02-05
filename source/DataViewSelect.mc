using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Application;
using Toybox.System;


var response_code = "None";


class DataViewSelect extends WatchUi.View {


    function initialize(selection_idx) {
        View.initialize();
        item_idx = selection_idx;
    }

    // Load your resources here
    function onLayout(dc) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_WHITE);
		dc.clear();  
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	
    	// Get current time information
    	time = getTime();
    	
    	// A function to load from storage data for the last n_days and put it in an array
    	current_data = loadHabitData(time["day_num"], n_days);	
    	
    }

    // Update the view
    function onUpdate(dc) {
		display_full(dc, item_idx);
		respond(response_code);
		response_code = "None";
    }        

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    
    	System.println(current_data);
    
    	saveCurrentData(current_data);
    
    }
	
}



class DataViewSelectDelegate extends WatchUi.InputDelegate {

    function initialize() {
		InputDelegate.initialize();
	}
	
    function onKey(keyEvent) {
    	
    	var key = keyEvent.getKey();
    	
    	if (key == up_key) {
    		up();
    	} else if (key == down_key) {
    		down();
    	} else if (key == start_key) {
    		response_code = change_datum(item_idx);
    	} else if (key == back_key) {
    		WatchUi.pushView(carousel_view, carousel_delegate, 2);
    	}
    	
    	System.println(response_code);
    	    	
        WatchUi.requestUpdate();
        return true;
    }
}
