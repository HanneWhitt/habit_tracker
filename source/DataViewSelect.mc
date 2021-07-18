using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Application;
using Toybox.System;


var response_code = null;


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
		
		// Writing all this to storage for development. All of this will be in storage already when app fully built. 
    	Application.Storage.setValue(h1_key, h1_val);
    	Application.Storage.setValue(h2_key, h2_val);
    	Application.Storage.setValue(h2_key2, h2_val2);
    	Application.Storage.setValue(h1_meta_key, h1_meta_val);
    	Application.Storage.setValue(h2_meta_key, h2_meta_val);
    	Application.Storage.setValue(all_habits_key, all_habits_val);
    	Application.Storage.setValue(current_habits_key, current_habits_val);
    	
    	
    	// App code start
    	
    	// Get current time information
    	time = getTime();
    	
    	// A function to load from storage data for the last n_days and put it in an array
    	current_data = loadCurrentData(time["day_num"], n_days);	
    	
    }

    // Update the view
    function onUpdate(dc) {
    
		display_full(dc, item_idx);
		respond(response_code);
		
    }        

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
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
    	}
    	
    	System.println(response_code);
    	    	
        WatchUi.requestUpdate();
        return true;
    }
}
