using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Application;
using Toybox.System;
using Toybox.Lang;


class DataViewInitial extends WatchUi.View {

    function initialize() {
        View.initialize();
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
		display_habit_data(dc, null);
    }        

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
	
}


class DataViewInitialDelegate extends WatchUi.InputDelegate {

    function initialize() {
		InputDelegate.initialize();
	}
	
    function onKey(keyEvent) {
    
		if (keyEvent.getKey() == start_key) {
			
			// initial day selection is -1 i.e display index of current day. 
    		WatchUi.pushView(new DataViewSelect(0), new DataViewSelectDelegate(), 1);
    	}
        return true;
    }
}

