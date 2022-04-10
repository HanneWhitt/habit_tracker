using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Application;
using Toybox.System;
using Toybox.Lang;


var current_daynum;
var current_data;


class DataViewInitial extends WatchUi.View {

    public var current_daynum;
    public var current_data;

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
    	
    	// Refresh current daynum
    	current_daynum = getTime()["day_num"];
    	    	
    	// Load the data from the last n_days
    	current_data = loadDaynumHabitData(active_habits, current_daynum);
    }

    // Update the view
    function onUpdate(dc) {
    
    	// Refresh the data if the day has changed (i.e if it has just passed midnight)
    	var new_daynum = getTime()["day_num"];
		if (new_daynum != current_daynum) {
	    	current_data = loadDaynumHabitData(active_habits, new_daynum);
	    	current_daynum = new_daynum;
		}
		    	
		display_habit_data(dc, current_data, null);
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
			WatchUi.pushView(selection_view, selection_delegate, 1);
    	}
        return true;
    }
}

